//
//  ServerStatus.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ServerStatus<T: Decodable>: Decodable {
    let status: String
    let detailed_status: String?  // Optional for errors
    let message: String?  // Optional for additional information
    let data: T?  // Generic payload
}
