import Foundation

struct APIConfiguration: Sendable {
    var baseURL: URL

    static let production = APIConfiguration(
        baseURL: URL(string: "http://127.0.0.1:8001/api/v1")!
    )
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int, String?)
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Risposta del server non valida."
        case let .httpStatus(code, detail):
            detail ?? "Errore HTTP \(code)."
        case .missingAccessToken:
            "Sessione non autenticata."
        }
    }
}

struct AuthenticatedUser: Codable, Sendable {
    let id: String
    let email: String
    let nome: String
    let ruolo: String
    let mustChangePassword: Bool

    enum CodingKeys: String, CodingKey {
        case id, email, nome, ruolo
        case mustChangePassword = "must_change_password"
    }
}

struct LoginResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let user: AuthenticatedUser

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

struct RemoteProperty: Codable, Sendable {
    let id: String
    let codice: String
    let titolo: String
    let indirizzo: String
    let unitaCount: Int

    enum CodingKeys: String, CodingKey {
        case id, codice, titolo, indirizzo
        case unitaCount = "unita_count"
    }
}

actor APIClient {
    private let configuration: APIConfiguration
    private let session: URLSession
    private var accessToken: String?
    private var refreshToken: String?

    init(
        configuration: APIConfiguration = .production,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }

    func setTokens(accessToken: String?, refreshToken: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        var request = URLRequest(url: configuration.baseURL.appending(path: "auth/login"))
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password),
        ]
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let response: LoginResponse = try await perform(request)
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        return response
    }

    func fetchProperties() async throws -> [RemoteProperty] {
        guard let accessToken else { throw APIError.missingAccessToken }

        var request = URLRequest(url: configuration.baseURL.appending(path: "immobili"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return try await perform(request)
    }

    func healthCheck() async throws {
        let request = URLRequest(url: configuration.baseURL.appending(path: "health"))
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpStatus(httpResponse.statusCode, nil)
        }
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let detail = (try? JSONSerialization.jsonObject(with: data))
                .flatMap { $0 as? [String: Any] }?["detail"] as? String
            throw APIError.httpStatus(httpResponse.statusCode, detail)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
