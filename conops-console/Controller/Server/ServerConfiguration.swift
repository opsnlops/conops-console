//
//  ServerConfiguration.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ServerConfiguration {
    static let hostnameKey = "serverHostname"
    static let portKey = "serverRestPort"
    static let useTLSKey = "useTLS"
    static let includeInactiveKey = "includeInactiveConventions"
    static let lastAuthConventionKey = "lastAuthConvention"
    static let lastAuthUsernameKey = "lastAuthUsername"

    static var defaultHostname: String { "127.0.0.1" }
    static var defaultPort: Int { 8080 }
    static var defaultUseTLS: Bool { false }
    static var defaultIncludeInactive: Bool { false }
    static var defaultLastAuthConvention: String { "" }
    static var defaultLastAuthUsername: String { "" }
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

    var includeInactiveConventions: Bool {
        get {
            object(forKey: ServerConfiguration.includeInactiveKey) as? Bool
                ?? ServerConfiguration.defaultIncludeInactive
        }
        set { set(newValue, forKey: ServerConfiguration.includeInactiveKey) }
    }

    var lastAuthConvention: String {
        get {
            string(forKey: ServerConfiguration.lastAuthConventionKey)
                ?? ServerConfiguration.defaultLastAuthConvention
        }
        set { set(newValue, forKey: ServerConfiguration.lastAuthConventionKey) }
    }

    var lastAuthUsername: String {
        get {
            string(forKey: ServerConfiguration.lastAuthUsernameKey)
                ?? ServerConfiguration.defaultLastAuthUsername
        }
        set { set(newValue, forKey: ServerConfiguration.lastAuthUsernameKey) }
    }
}
