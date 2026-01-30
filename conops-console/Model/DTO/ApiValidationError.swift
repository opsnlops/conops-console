//  ApiValidationError.swift
//  conops-console
//
//  Created by April White on 1/28/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ApiValidationError: Decodable, Hashable {
    let field: String
    let message: String
}
