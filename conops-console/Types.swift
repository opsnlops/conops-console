//
//  Types.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

/**
 These are various types used in the system
 */

public typealias ConventionIdentifier = Int
public typealias AttendeeIdentifier = Int
public typealias MembershipLevelIdentifier = Int

public enum AttendeeType: String, Codable, Sendable {
    case staff
    case dealer
    case staffDealer

    var isStaff: Bool {
        switch self {
        case .staff, .staffDealer:
            return true
        case .dealer:
            return false
        }
    }

    var isDealer: Bool {
        switch self {
        case .dealer, .staffDealer:
            return true
        case .staff:
            return false
        }
    }
}

public enum TransactionTypeOption: Int, CaseIterable, Identifiable {
    case cashIn = 0
    case payPalIn = 1
    case creditCardIn = 2
    case cashOut = 10
    case payPalOut = 11
    case creditCardOut = 12
    case registrationFee = 100
    case registrationUpgrade = 101
    case registrationDowngrade = 102
    case registrationRefund = 150
    case dealerFee = 200
    case dealerRefund = 250
    case merchandiseSale = 300
    case merchandiseRefund = 350
    case comp = 400
    case other = 500

    public var id: Int { rawValue }

    public var description: String {
        switch self {
        case .cashIn:
            return "Cash In"
        case .payPalIn:
            return "PayPal In"
        case .creditCardIn:
            return "Credit Card In"
        case .cashOut:
            return "Cash Out"
        case .payPalOut:
            return "PayPal Out"
        case .creditCardOut:
            return "Credit Card Out"
        case .registrationFee:
            return "Registration Fee"
        case .registrationUpgrade:
            return "Registration Upgrade"
        case .registrationDowngrade:
            return "Registration Downgrade"
        case .registrationRefund:
            return "Registration Refund"
        case .dealerFee:
            return "Dealer Fee"
        case .dealerRefund:
            return "Dealer Refund"
        case .merchandiseSale:
            return "Merchandise Sale"
        case .merchandiseRefund:
            return "Merchandise Refund"
        case .comp:
            return "Approved Comp"
        case .other:
            return "Other"
        }
    }
}

public struct PendingTransaction: Identifiable, Hashable {
    public let id: UUID
    public let amount: Float
    public let type: TransactionTypeOption
    public let notes: String

    public init(amount: Float, type: TransactionTypeOption, notes: String) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.notes = notes
    }
}
