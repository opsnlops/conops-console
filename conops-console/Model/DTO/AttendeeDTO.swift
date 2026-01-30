//
//  AttendeeDTO.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

private struct DateOnly: Codable {
    let value: Date

    init(_ value: Date) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        let parts = dateString.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
        }

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone.current
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        components.second = 0

        guard let date = components.date else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
        }

        self.value = date
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone.current, from: value)
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid date"
            ))
        }
        let dateString = String(format: "%04d-%02d-%02d", year, month, day)
        try container.encode(dateString)
    }
}

struct AttendeeDTO: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: AttendeeIdentifier
    let conventionId: ConventionIdentifier
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
    let referral: String?
    let registrationDate: Date
    let checkInTime: Date?
    let staff: Bool
    let dealer: Bool
    let attendeeType: AttendeeType
    let codeOfConductAccepted: Bool
    let secretCode: String?
    let currentBalance: Float
    let transactions: [Transaction]

    enum CodingKeys: String, CodingKey {
        case id
        case conventionId = "convention_id"
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
        case referral
        case registrationDate = "registration_date"
        case checkInTime = "check_in_time"
        case staff
        case dealer
        case attendeeType = "attendee_type"
        case codeOfConductAccepted = "code_of_conduct_accepted"
        case secretCode = "secret_code"
        case currentBalance = "current_balance"
        case transactions
    }

    static func < (lhs: AttendeeDTO, rhs: AttendeeDTO) -> Bool {
        lhs.badgeName.localizedCaseInsensitiveCompare(rhs.badgeName) == .orderedAscending
    }

    static func mock() -> AttendeeDTO {
        return AttendeeDTO(
            id: AttendeeIdentifier(),
            conventionId: ConventionIdentifier(),
            lastModified: Date(),
            active: true,
            badgeNumber: 1234,
            firstName: "Mock",
            lastName: "Attendee",
            badgeName: "Mocky",
            membershipLevel: MembershipLevelIdentifier(),
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
            referral: "MockReferral",
            registrationDate: Date(),
            checkInTime: Date().addingTimeInterval(-3600),
            staff: false,
            dealer: false,
            attendeeType: .staff,
            codeOfConductAccepted: true,
            secretCode: "MockSecret",
            currentBalance: 0.0,
            transactions: [Transaction.mock()]
        )
    }
}


// MARK: - AttendeeDTO Codable
extension AttendeeDTO {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(conventionId, forKey: .conventionId)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(active, forKey: .active)
        try container.encode(badgeNumber, forKey: .badgeNumber)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(badgeName, forKey: .badgeName)
        try container.encode(membershipLevel, forKey: .membershipLevel)
        try container.encode(DateOnly(birthday), forKey: .birthday)
        try container.encode(addressLine1, forKey: .addressLine1)
        try container.encode(addressLine2, forKey: .addressLine2)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(shirtSize, forKey: .shirtSize)
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(emergencyContact, forKey: .emergencyContact)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(referral, forKey: .referral)
        try container.encode(registrationDate, forKey: .registrationDate)
        try container.encode(checkInTime, forKey: .checkInTime)
        try container.encode(staff, forKey: .staff)
        try container.encode(dealer, forKey: .dealer)
        try container.encode(attendeeType, forKey: .attendeeType)
        try container.encode(codeOfConductAccepted, forKey: .codeOfConductAccepted)
        try container.encode(secretCode, forKey: .secretCode)
        try container.encode(currentBalance, forKey: .currentBalance)
        try container.encode(transactions, forKey: .transactions)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(AttendeeIdentifier.self, forKey: .id)
        self.conventionId = try container.decode(ConventionIdentifier.self, forKey: .conventionId)
        self.lastModified = try container.decode(Date.self, forKey: .lastModified)
        self.active = try container.decode(Bool.self, forKey: .active)
        self.badgeNumber = try container.decode(UInt32.self, forKey: .badgeNumber)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.badgeName = try container.decode(String.self, forKey: .badgeName)
        self.membershipLevel = try container.decode(MembershipLevelIdentifier.self, forKey: .membershipLevel)
        self.birthday = try container.decode(DateOnly.self, forKey: .birthday).value
        self.addressLine1 = try container.decode(String.self, forKey: .addressLine1)
        self.addressLine2 = try container.decodeIfPresent(String.self, forKey: .addressLine2)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.postalCode = try container.decode(String.self, forKey: .postalCode)
        self.shirtSize = try container.decodeIfPresent(String.self, forKey: .shirtSize)
        self.emailAddress = try container.decode(String.self, forKey: .emailAddress)
        self.emergencyContact = try container.decodeIfPresent(
            String.self, forKey: .emergencyContact)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.referral = try container.decodeIfPresent(String.self, forKey: .referral)
        self.registrationDate = try container.decode(Date.self, forKey: .registrationDate)
        self.checkInTime = try container.decodeIfPresent(Date.self, forKey: .checkInTime)
        self.staff = try container.decode(Bool.self, forKey: .staff)
        self.dealer = try container.decode(Bool.self, forKey: .dealer)
        self.attendeeType = try container.decodeIfPresent(AttendeeType.self, forKey: .attendeeType) ?? .staff
        self.codeOfConductAccepted = try container.decode(Bool.self, forKey: .codeOfConductAccepted)
        self.secretCode = try container.decodeIfPresent(String.self, forKey: .secretCode)
        self.currentBalance = try container.decodeIfPresent(Float.self, forKey: .currentBalance) ?? 0.0
        self.transactions = try container.decode([Transaction].self, forKey: .transactions)
    }
}
