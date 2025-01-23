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


    var body: some Scene {
        WindowGroup {
            TopContentView()
        }
        .modelContainer(for: [Attendee.self, Convention.self])

        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
