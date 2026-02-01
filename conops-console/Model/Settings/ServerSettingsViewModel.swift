//
//  ServerSettingsViewModel.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

class ServerSettingsViewModel: ObservableObject {
    @Published var hostname: String {
        didSet { UserDefaults.standard.serverHostname = hostname }
    }
    @Published var port: Int {
        didSet { UserDefaults.standard.serverPort = port }
    }
    @Published var useTLS: Bool {
        didSet { UserDefaults.standard.useTLS = useTLS }
    }
    @Published var includeInactiveConventions: Bool {
        didSet { UserDefaults.standard.includeInactiveConventions = includeInactiveConventions }
    }

    init() {
        self.hostname = UserDefaults.standard.serverHostname
        self.port = UserDefaults.standard.serverPort
        self.useTLS = UserDefaults.standard.useTLS
        self.includeInactiveConventions = UserDefaults.standard.includeInactiveConventions
    }

    func resetToDefaults() {
        hostname = ServerConfiguration.defaultHostname
        port = ServerConfiguration.defaultPort
        useTLS = ServerConfiguration.defaultUseTLS
        includeInactiveConventions = ServerConfiguration.defaultIncludeInactive
    }
}
