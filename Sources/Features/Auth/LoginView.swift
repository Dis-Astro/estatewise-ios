import SwiftUI

struct LoginView: View {
    @Environment(AppSession.self) private var session

    @State private var serverURL = APIConfiguration.storedBaseURLString
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("URL API", text: $serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }

                Section("Accesso") {
                    TextField("Email", text: $email)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }

                if let errorMessage = session.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            await session.signIn(
                                serverURL: serverURL,
                                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                password: password
                            )
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if session.state == .authenticating {
                                ProgressView()
                            } else {
                                Text("Accedi")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(
                        serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        password.isEmpty ||
                        session.state == .authenticating
                    )
                }
            }
            .navigationTitle("EstateWise")
        }
    }
}
