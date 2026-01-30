import OSLog
import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var conventionShortName: String
    @State private var username: String
    @State private var password: String = ""
    @State private var conventions: [PublicConventionDTO] = []
    @State private var isLoadingConventions = false
    @State private var conventionLoadError: String?
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let logger = Logger(subsystem: "furry.enterprises.ConopsConsole", category: "LoginView")
    private let onAuthenticated: () -> Void

    init(onAuthenticated: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        _conventionShortName = State(initialValue: defaults.lastAuthConvention)
        _username = State(initialValue: defaults.lastAuthUsername)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sign in")
                .font(.title2)

            if conventions.isEmpty {
                TextField("Convention short name", text: $conventionShortName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
            } else {
                Picker("Convention", selection: $conventionShortName) {
                    ForEach(conventions, id: \.shortName) { convention in
                        Text(convention.longName)
                            .tag(convention.shortName)
                    }
                }
                #if os(macOS)
                    .pickerStyle(.menu)
                #endif
            }

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                #if os(iOS)
                    .textInputAutocapitalization(.never)
                #endif

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                #if os(iOS)
                    .textInputAutocapitalization(.never)
                #endif

            if let conventionLoadError {
                Text(conventionLoadError)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Sign in") {
                    Task { await submit() }
                }
                .disabled(isSubmitting || !canSubmit)
            }
        }
        .padding(24)
        .frame(minWidth: 320)
        #if os(iOS)
            .interactiveDismissDisabled(true)
        #endif
        .task {
            await loadConventions()
        }
    }

    private var canSubmit: Bool {
        !conventionShortName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
    }

    private func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil

        let client = ConopsServerClient()
        let result = await client.requestAuthToken(
            conventionShortName: conventionShortName,
            username: username,
            password: password
        )

        switch result {
        case .success(let response):
            logger.info("Authenticated as \(username)")
            AuthStore.shared.save(token: response.accessToken)
            UserDefaults.standard.lastAuthConvention = conventionShortName
            UserDefaults.standard.lastAuthUsername = username
            dismiss()
            onAuthenticated()
        case .failure(let error):
            logger.error("Login failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    private func loadConventions() async {
        guard conventions.isEmpty, !isLoadingConventions else { return }
        isLoadingConventions = true
        conventionLoadError = nil

        let client = ConopsServerClient()
        let result = await client.getActiveConventionsPublic()
        switch result {
        case .success(let conventions):
            await MainActor.run {
                self.conventions = conventions
                if conventionShortName.isEmpty {
                    conventionShortName = conventions.first?.shortName ?? ""
                }
            }
        case .failure(let error):
            await MainActor.run {
                conventionLoadError = "Unable to load conventions: \(error.localizedDescription)"
            }
        }

        isLoadingConventions = false
    }
}

#Preview {
    LoginView(onAuthenticated: {})
}
