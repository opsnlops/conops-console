//
//  ServerSettingsView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import OSLog
import SwiftData
import SwiftUI

struct ServerSettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var pushManager = PushNotificationManager.shared
    @StateObject private var viewModel = ServerSettingsViewModel()
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showResetConfirmation = false
    @State private var showResetSuccessAlert = false
    @State private var resetSuccessMessage = ""

    private let logger = Logger(
        subsystem: "furry.enterprises.ConopsConsole", category: "ServerSettings")

    var body: some View {
        Form {
            Section(header: Text("Server Configuration")) {
                TextField("Hostname", text: $viewModel.hostname)
                    .disableAutocorrection(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.none)
                    #endif

                TextField("Port", value: $viewModel.port, format: .number)

                Toggle("Use TLS", isOn: $viewModel.useTLS)
            }

            Section(header: Text("Sync Options")) {
                Toggle("Include Inactive Conventions", isOn: $viewModel.includeInactiveConventions)
            }

            Section(header: Text("Display Options")) {
                Toggle("Show Inactive Attendees", isOn: $viewModel.showInactiveAttendees)
            }

            Section(header: Text("Local Data")) {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Reset Local Database")
                }
            }

            Section {
                Button(action: {
                    viewModel.resetToDefaults()
                }) {
                    Text("Reset to Defaults")
                        .foregroundColor(.red)
                }
            }

            Section(header: Text("Device")) {
                if let token = pushManager.deviceToken {
                    TextField("APNs Device Token", text: .constant(token))
                        .textSelection(.enabled)
                        #if os(iOS)
                            .font(.system(.caption, design: .monospaced))
                        #elseif os(macOS)
                            .font(.system(.body, design: .monospaced))
                        #endif
                } else {
                    Text("No device token")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Authentication")) {
                Button {
                    Task {
                        let result = await MainActor.run {
                            SessionManager.logout(
                                context: context, appState: appState, logger: logger)
                        }
                        if case .failure(let error) = result {
                            await MainActor.run {
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                            }
                        } else {
                            await MainActor.run {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Log Out and Clear Cache")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Logout Failed"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showResetSuccessAlert) {
            Alert(
                title: Text("Local Cache Cleared"),
                message: Text(resetSuccessMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .confirmationDialog(
            "Reset the local SwiftData cache?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Local Database", role: .destructive) {
                Task {
                    let result = await MainActor.run {
                        SyncCache.clear(context: context, logger: logger)
                    }
                    if case .failure(let error) = result {
                        await MainActor.run {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    } else {
                        await MainActor.run {
                            resetSuccessMessage = "The local SwiftData cache has been cleared."
                            showResetSuccessAlert = true
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Server Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSettingsView()
    }
}
