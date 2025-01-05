//
//  ServerSettingsViewModel.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
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

    init() {
        self.hostname = UserDefaults.standard.serverHostname
        self.port = UserDefaults.standard.serverPort
        self.useTLS = UserDefaults.standard.useTLS
    }

    func resetToDefaults() {
        hostname = ServerConfiguration.defaultHostname
        port = ServerConfiguration.defaultPort
        useTLS = ServerConfiguration.defaultUseTLS
    }
}
