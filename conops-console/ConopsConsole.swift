//
//  Conops Console.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//

import Foundation
import SwiftData
import SwiftUI

@main
struct ConopsConsoleApp: App {

    @StateObject private var appState = AppState()


    init() {
        initializeDefaults()
    }

    private func initializeDefaults() {
        UserDefaults.standard.register(defaults: [
            ServerConfiguration.hostnameKey: ServerConfiguration.defaultHostname,
            ServerConfiguration.portKey: ServerConfiguration.defaultPort,
            ServerConfiguration.useTLSKey: ServerConfiguration.defaultUseTLS,
            ServerConfiguration.includeInactiveKey: ServerConfiguration.defaultIncludeInactive,
            ServerConfiguration.lastAuthConventionKey: ServerConfiguration.defaultLastAuthConvention,
            ServerConfiguration.lastAuthUsernameKey: ServerConfiguration.defaultLastAuthUsername,
        ])
    }


    var body: some Scene {
        WindowGroup {
            TopContentView()
                .environmentObject(appState)
        }
        .modelContainer(for: [Attendee.self, Convention.self, SyncState.self])
        #if os(macOS) || os(iOS)
            .commands {
                ConventionCommands(appState: appState)
            }
        #endif

        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
