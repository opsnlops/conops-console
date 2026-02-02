//
//  ServerError.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

public enum ServerError: Error, LocalizedError {
    case communicationError(String)
    case dataFormatError(String)
    case otherError(String)
    case databaseError(String)
    case notFound(String)
    case unknownError(String)
    case serverError(String)
    case websocketError(String)
    case unprocessableEntity(String)
    case notImplemented(String)
    case apiError(Int, String)


    public var errorDescription: String? {
        switch self {
        case .communicationError(let message),
            .dataFormatError(let message),
            .otherError(let message),
            .databaseError(let message),
            .notFound(let message),
            .unknownError(let message),
            .serverError(let message),
            .websocketError(let message),
            .unprocessableEntity(let message),
            .notImplemented(let message):
            return message
        case .apiError(let code, let message):
            return "API error \(code): \(message)"
        }
    }
}
