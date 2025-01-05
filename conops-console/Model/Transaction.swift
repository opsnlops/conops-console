//
//  Transaction.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct Transaction: Codable, Identifiable, Comparable, Hashable {
    let id: UUID
    let amount: Float
    let transactionTime: Date
    let paymentReference: String?
    let paymentStatus: String?
    let paymentDetails: String?
    let userName: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case transactionTime = "transaction_time"
        case paymentReference = "payment_reference"
        case paymentStatus = "payment_status"
        case paymentDetails = "payment_details"
        case userName = "user_name"
        case notes
    }

    static func < (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.transactionTime < rhs.transactionTime
    }

    static func mock() -> Transaction {
        Transaction(
            id: UUID(),
            amount: 123.45,
            transactionTime: Date(),
            paymentReference: "MockPaymentRef",
            paymentStatus: "Completed",
            paymentDetails: "Mock payment details",
            userName: "Mock User",
            notes: "Mock transaction notes"
        )
    }
}
