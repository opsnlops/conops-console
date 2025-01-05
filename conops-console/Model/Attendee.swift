//
//  Attendee.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct Attendee: Codable, Identifiable, Comparable, Hashable {
    let id: UUID
    let active: Bool
    let badgeNumber: UInt32
    let firstName: String
    let lastName: String
    let badgeName: String
    let membershipLevel: MembershipLevel
    let birthday: Date
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let postalCode: String
    let shirtSize: String?
    let emailAddress: String
    let emergencyContact: String?
    let phoneNumber: String?
    let registrationDate: Date
    let checkInTime: Date?
    let staff: Bool
    let dealer: Bool
    let codeOfConductAccepted: Bool
    let secretCode: String?
    let transactions: [Transaction]

    enum CodingKeys: String, CodingKey {
        case id
        case active
        case badgeNumber = "badge_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case badgeName = "badge_name"
        case membershipLevel = "membership_level"
        case birthday
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city
        case state
        case postalCode = "postal_code"
        case shirtSize = "shirt_size"
        case emailAddress = "email_address"
        case emergencyContact = "emergency_contact"
        case phoneNumber = "phone_number"
        case registrationDate = "registration_date"
        case checkInTime = "check_in_time"
        case staff
        case dealer
        case codeOfConductAccepted = "code_of_conduct_accepted"
        case secretCode = "secret_code"
        case transactions
    }

    static func < (lhs: Attendee, rhs: Attendee) -> Bool {
        lhs.badgeName.localizedCaseInsensitiveCompare(rhs.badgeName) == .orderedAscending
    }

    static func mock() -> Attendee {
        Attendee(
            id: UUID(),
            active: true,
            badgeNumber: 1234,
            firstName: "Mock",
            lastName: "Attendee",
            badgeName: "Mocky",
            membershipLevel: MembershipLevel.mock(),
            birthday: Date(),
            addressLine1: "123 Mock St",
            addressLine2: "Apt 4B",
            city: "Mock City",
            state: "WA",
            postalCode: "12345",
            shirtSize: "Medium",
            emailAddress: "mock@example.com",
            emergencyContact: "Mock Contact",
            phoneNumber: "123-456-7890",
            registrationDate: Date(),
            checkInTime: Date().addingTimeInterval(-3600),
            staff: false,
            dealer: false,
            codeOfConductAccepted: true,
            secretCode: "MockSecret",
            transactions: [Transaction.mock()]
        )
    }
}