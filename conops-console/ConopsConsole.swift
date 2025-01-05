//
//  conops_consoleApp.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//

import SwiftData
import SwiftUI

@main
struct ConopsConsoleApp: App {


    init() {
        initializeDefaults()
    }

    private func initializeDefaults() {
        UserDefaults.standard.register(defaults: [
            ServerConfiguration.hostnameKey: ServerConfiguration.defaultHostname,
            ServerConfiguration.portKey: ServerConfiguration.defaultPort,
            ServerConfiguration.useTLSKey: ServerConfiguration.defaultUseTLS,
        ])
    }


    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TopContentView()
        }
        .modelContainer(sharedModelContainer)

        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
