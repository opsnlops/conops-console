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
    @State private var showServerSettings = false
    @State private var serverHostname: String
    @State private var serverPort: String
    @State private var useTLS: Bool

    private let logger = Logger(subsystem: "furry.enterprises.ConopsConsole", category: "LoginView")
    private let canCancel: Bool
    private let onAuthenticated: () -> Void
    private let onCancel: (() -> Void)?

    init(
        canCancel: Bool = false,
        onAuthenticated: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let defaults = UserDefaults.standard
        _conventionShortName = State(initialValue: defaults.lastAuthConvention)
        _username = State(initialValue: defaults.lastAuthUsername)
        _serverHostname = State(initialValue: defaults.serverHostname)
        _serverPort = State(initialValue: String(defaults.serverPort))
        _useTLS = State(initialValue: defaults.useTLS)
        self.canCancel = canCancel
        self.onAuthenticated = onAuthenticated
        self.onCancel = onCancel
    }

    var body: some View {
        #if os(iOS)
            NavigationStack {
                Form {
                    conventionSection
                    credentialsSection
                    errorSection
                    serverSettingsSection
                }
                .navigationTitle("Sign In")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if canCancel {
                            Button("Cancel") {
                                onCancel?()
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Button("Sign In") {
                                Task { await submit() }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canSubmit)
                        }
                    }
                }
                .interactiveDismissDisabled(!canCancel)
            }
            .task {
                await loadConventions()
            }
        #else
            VStack(spacing: 0) {
                Form {
                    conventionSection
                    credentialsSection
                    errorSection
                    serverSettingsSection
                }
                .formStyle(.grouped)

                Divider()

                HStack {
                    if canCancel {
                        Button("Cancel") {
                            onCancel?()
                            dismiss()
                        }
                        .keyboardShortcut(.cancelAction)
                    }
                    Spacer()
                    if isSubmitting {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 8)
                    }
                    Button("Sign In") {
                        Task { await submit() }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(isSubmitting || !canSubmit)
                }
                .padding()
            }
            .frame(width: 400, height: 450)
            .task {
                await loadConventions()
            }
        #endif
    }

    @ViewBuilder
    private var conventionSection: some View {
        Section {
            if isLoadingConventions {
                HStack {
                    Text("Loading conventions...")
                        .foregroundStyle(.secondary)
                    Spacer()
                    ProgressView()
                }
            } else if conventions.isEmpty {
                TextField("Convention short name", text: $conventionShortName)
                    .autocorrectionDisabled()
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .textContentType(.organizationName)
                    #endif
            } else {
                Picker("Convention", selection: $conventionShortName) {
                    ForEach(conventions, id: \.shortName) { convention in
                        Text(convention.longName)
                            .tag(convention.shortName)
                    }
                }
            }
        } header: {
            Text("Convention")
        } footer: {
            if let conventionLoadError {
                Text(conventionLoadError)
            }
        }
    }

    @ViewBuilder
    private var credentialsSection: some View {
        Section("Credentials") {
            TextField("Username", text: $username)
                .autocorrectionDisabled()
                #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                #endif

            SecureField("Password", text: $password)
                #if os(iOS)
                    .textContentType(.password)
                #endif
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage {
            Section {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var serverSettingsSection: some View {
        Section {
            DisclosureGroup("Server Settings", isExpanded: $showServerSettings) {
                TextField("Hostname", text: $serverHostname)
                    .autocorrectionDisabled()
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    #endif

                TextField("Port", text: $serverPort)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif

                Toggle("Use TLS (HTTPS)", isOn: $useTLS)

                Button("Save & Reload") {
                    saveServerSettings()
                    Task { await reloadConventions() }
                }
                .disabled(serverHostname.isEmpty || serverPort.isEmpty)
            }
        }
    }

    private func saveServerSettings() {
        let defaults = UserDefaults.standard
        defaults.serverHostname = serverHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        if let port = Int(serverPort) {
            defaults.serverPort = port
        }
        defaults.useTLS = useTLS
        logger.info("Server settings saved: \(serverHostname):\(serverPort) TLS=\(useTLS)")
    }

    private func reloadConventions() async {
        conventions = []
        conventionLoadError = nil
        await loadConventions()
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

#Preview("With Cancel") {
    LoginView(canCancel: true, onAuthenticated: {}, onCancel: {})
}
