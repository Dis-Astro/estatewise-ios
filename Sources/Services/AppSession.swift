import Foundation
import Observation

@MainActor
@Observable
final class AppSession {
    enum State: Equatable {
        case signedOut
        case authenticating
        case signedIn
    }

    private(set) var state: State = .signedOut
    private(set) var user: AuthenticatedUser?
    var errorMessage: String?

    let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func signIn(email: String, password: String) async {
        guard state != .authenticating else { return }
        state = .authenticating
        errorMessage = nil

        do {
            let response = try await apiClient.login(email: email, password: password)
            user = response.user
            state = .signedIn
        } catch {
            user = nil
            state = .signedOut
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        await apiClient.setTokens(accessToken: nil, refreshToken: nil)
        user = nil
        errorMessage = nil
        state = .signedOut
    }
}
