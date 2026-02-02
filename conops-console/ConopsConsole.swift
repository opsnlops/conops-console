//
//  Conops Console.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

@main
struct ConopsConsoleApp: App {

    @StateObject private var appState = AppState()
    @StateObject private var authManager = BiometricAuthManager()
    @Environment(\.scenePhase) private var scenePhase
    let modelContainer: ModelContainer

    private static let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "ConopsConsoleApp"
    )

    init() {
        Self.initializeDefaults()

        // Create model container with schema migration handling
        do {
            let schema = Schema([Attendee.self, Convention.self, SyncState.self])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // If the schema is incompatible, delete and recreate
            Self.logger.error("Failed to create model container: \(error). Attempting recovery...")

            do {
                let schema = Schema([Attendee.self, Convention.self, SyncState.self])
                let config = ModelConfiguration(schema: schema)

                // Try to delete the existing store
                let storeURL = config.url
                try? FileManager.default.removeItem(at: storeURL)
                // Also remove the -wal and -shm files
                try? FileManager.default.removeItem(
                    at: storeURL.appendingPathExtension("wal"))
                try? FileManager.default.removeItem(
                    at: storeURL.appendingPathExtension("shm"))
                Self.logger.info("Deleted existing store at \(storeURL.path)")

                modelContainer = try ModelContainer(for: schema, configurations: [config])
                Self.logger.info("Successfully recreated model container")
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    private static func initializeDefaults() {
        UserDefaults.standard.register(defaults: [
            ServerConfiguration.hostnameKey: ServerConfiguration.defaultHostname,
            ServerConfiguration.portKey: ServerConfiguration.defaultPort,
            ServerConfiguration.useTLSKey: ServerConfiguration.defaultUseTLS,
            ServerConfiguration.includeInactiveKey: ServerConfiguration.defaultIncludeInactive,
            ServerConfiguration.showInactiveAttendeesKey: ServerConfiguration
                .defaultShowInactiveAttendees,
            ServerConfiguration.lastAuthConventionKey: ServerConfiguration
                .defaultLastAuthConvention,
            ServerConfiguration.lastAuthUsernameKey: ServerConfiguration.defaultLastAuthUsername,
        ])
    }


    var body: some Scene {
        WindowGroup {
            ZStack {
                TopContentView()
                    .environmentObject(appState)

                if authManager.requiresBiometrics && !authManager.isUnlocked {
                    LockScreenView(authManager: authManager)
                }
            }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
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

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // Lock when going to background
            authManager.lock()
        case .active:
            // Prompt for auth when becoming active if locked
            if authManager.requiresBiometrics && !authManager.isUnlocked {
                authManager.authenticate()
            }
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
