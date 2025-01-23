//
//  AttendeeDTO.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct AttendeeDTO: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: AttendeeIdentifier
    let lastModified: Date
    let active: Bool
    let badgeNumber: UInt32
    let firstName: String
    let lastName: String
    let badgeName: String
    let membershipLevel: MembershipLevelIdentifier
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
        case lastModified = "last_modified"
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

    static func < (lhs: AttendeeDTO, rhs: AttendeeDTO) -> Bool {
        lhs.badgeName.localizedCaseInsensitiveCompare(rhs.badgeName) == .orderedAscending
    }

    static func mock() -> AttendeeDTO {
        return AttendeeDTO(
            id: UUID(),
            lastModified: Date(),
            active: true,
            badgeNumber: 1234,
            firstName: "Mock",
            lastName: "Attendee",
            badgeName: "Mocky",
            membershipLevel: UUID(),
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
