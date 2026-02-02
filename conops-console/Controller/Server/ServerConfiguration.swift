//
//  ServerConfiguration.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ServerConfiguration {
    static let hostnameKey = "conops.server.hostname"
    static let portKey = "conops.server.port"
    static let useTLSKey = "conops.server.useTLS"
    static let includeInactiveKey = "conops.server.includeInactiveConventions"
    static let showInactiveAttendeesKey = "conops.display.showInactiveAttendees"
    static let lastAuthConventionKey = "conops.auth.lastConvention"
    static let lastAuthUsernameKey = "conops.auth.lastUsername"

    static var defaultHostname: String { "furry.enterprises" }
    static var defaultPort: Int { 443 }
    static var defaultUseTLS: Bool { true }
    static var defaultIncludeInactive: Bool { false }
    static var defaultShowInactiveAttendees: Bool { false }
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
        get {
            let value = object(forKey: ServerConfiguration.portKey) as? Int
            return value ?? ServerConfiguration.defaultPort
        }
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

    var showInactiveAttendees: Bool {
        get {
            object(forKey: ServerConfiguration.showInactiveAttendeesKey) as? Bool
                ?? ServerConfiguration.defaultShowInactiveAttendees
        }
        set { set(newValue, forKey: ServerConfiguration.showInactiveAttendeesKey) }
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
