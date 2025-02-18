//
//  ActiveAlert.swift
//  Conops Console
//
//  Created by April White on 2/17/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

// Used for dealing with several alerts on one form

enum ActiveAlert: Identifiable {
    case success, error

    var id: Int {
        switch self {
        case .success: return 1
        case .error: return 2
        }
    }
}
