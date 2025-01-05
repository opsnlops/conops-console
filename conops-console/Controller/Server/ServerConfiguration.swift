//
//  ServerConfiguration.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ServerConfiguration {
    static let hostnameKey = "serverHostname"
    static let portKey = "serverRestPort"
    static let useTLSKey = "useTLS"

    static var defaultHostname: String { "127.0.0.1" }
    static var defaultPort: Int { 8000 }
    static var defaultUseTLS: Bool { false }
}

extension UserDefaults {
    var serverHostname: String {
        get {
            string(forKey: ServerConfiguration.hostnameKey) ?? ServerConfiguration.defaultHostname
        }
        set { set(newValue, forKey: ServerConfiguration.hostnameKey) }
    }

    var serverPort: Int {
        get { integer(forKey: ServerConfiguration.portKey) }
        set { set(newValue, forKey: ServerConfiguration.portKey) }
    }

    var useTLS: Bool {
        get {
            object(forKey: ServerConfiguration.useTLSKey) as? Bool
                ?? ServerConfiguration.defaultUseTLS
        }
        set { set(newValue, forKey: ServerConfiguration.useTLSKey) }
    }
}
