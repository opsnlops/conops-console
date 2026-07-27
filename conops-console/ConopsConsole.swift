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

    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    @StateObject private var appState = AppState()
    @StateObject private var authManager = BiometricAuthManager()
    @StateObject private var pushManager = PushNotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    let modelContainer: ModelContainer

    private static let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "ConopsConsoleApp"
    )

    init() {
        Self.initializeDefaults()

        Self.purgeStoreIfCredentialsMayBeResident()

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

    /// Bump this when a change requires wiping every device's local store.
    private static let storePurgeGeneration = 1
    private static let storePurgeGenerationKey = "conops.store.purgeGeneration"

    /// Deletes the local store once, the first time a device runs a build whose
    /// purge generation is newer than the one it last completed.
    ///
    /// Generation 1: until 1.2.0 the Convention model persisted third-party
    /// service credentials (Slack, Postmark, Twilio, PayPal, messaging) in
    /// plaintext. Dropping those properties stops new syncs from writing them,
    /// but it does not guarantee the old values are gone — depending on how
    /// SwiftData migrates, the bytes can survive in freed SQLite pages and in
    /// the -wal journal. Deleting the store is the only way to be certain.
    ///
    /// The cost is one full re-sync from the server on first launch after the
    /// upgrade, which is the same path the migration-failure fallback below
    /// already relies on.
    private static func purgeStoreIfCredentialsMayBeResident() {
        let defaults = UserDefaults.standard
        let completed = defaults.integer(forKey: storePurgeGenerationKey)
        guard completed < storePurgeGeneration else { return }

        let schema = Schema([Attendee.self, Convention.self, SyncState.self])
        let storeURL = ModelConfiguration(schema: schema).url

        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))

        // Record completion even if the files were already absent (fresh
        // install), so this runs at most once per generation.
        defaults.set(storePurgeGeneration, forKey: storePurgeGenerationKey)
        logger.info(
            "Purged local store for generation \(storePurgeGeneration); will re-sync from server")
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
