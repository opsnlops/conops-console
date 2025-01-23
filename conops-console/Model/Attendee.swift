//
//  Attendee.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Attendee {
    @Attribute(.unique) var id: AttendeeIdentifier
    var convention: Convention?
    var lastModified: Date
    var active: Bool
    var badgeNumber: UInt32
    var firstName: String
    var lastName: String
    var badgeName: String
    var membershipLevel: MembershipLevel = MembershipLevel.mock()
    var birthday: Date
    var addressLine1: String
    var addressLine2: String?
    var city: String
    var state: String
    var postalCode: String
    var shirtSize: String?
    var emailAddress: String
    var emergencyContact: String?
    var phoneNumber: String?
    var registrationDate: Date
    var checkInTime: Date?
    var staff: Bool
    var dealer: Bool
    var codeOfConductAccepted: Bool
    var secretCode: String?
    var transactions: [Transaction]

    init(
        id: AttendeeIdentifier,
        convention: Convention?,
        lastModified: Date,
        active: Bool,
        badgeNumber: UInt32,
        firstName: String,
        lastName: String,
        badgeName: String,
        membershipLevel: MembershipLevel,
        birthday: Date,
        addressLine1: String,
        addressLine2: String?,
        city: String,
        state: String,
        postalCode: String,
        shirtSize: String?,
        emailAddress: String,
        emergencyContact: String?,
        phoneNumber: String?,
        registrationDate: Date,
        checkInTime: Date?,
        staff: Bool,
        dealer: Bool,
        codeOfConductAccepted: Bool,
        secretCode: String?,
        transactions: [Transaction]
    ) {
        self.id = id
        self.lastModified = lastModified
        self.active = active
        self.badgeNumber = badgeNumber
        self.firstName = firstName
        self.lastName = lastName
        self.badgeName = badgeName
        self.membershipLevel = membershipLevel
        self.birthday = birthday
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.shirtSize = shirtSize
        self.emailAddress = emailAddress
        self.emergencyContact = emergencyContact
        self.phoneNumber = phoneNumber
        self.registrationDate = registrationDate
        self.checkInTime = checkInTime
        self.staff = staff
        self.dealer = dealer
        self.codeOfConductAccepted = codeOfConductAccepted
        self.secretCode = secretCode
        self.transactions = transactions
    }
}

// MARK: - DTO conversions
extension Attendee {
    static func fromDTO(_ dto: AttendeeDTO) -> Attendee {
        return Attendee(
            id: dto.id,

            //TODO: Figure out how to get this out of the model
            convention: nil,

            lastModified: dto.lastModified,
            active: dto.active,
            badgeNumber: dto.badgeNumber,
            firstName: dto.firstName,
            lastName: dto.lastName,
            badgeName: dto.badgeName,
            membershipLevel: dto.membershipLevel,
            birthday: dto.birthday,
            addressLine1: dto.addressLine1,
            addressLine2: dto.addressLine2,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            shirtSize: dto.shirtSize,
            emailAddress: dto.emailAddress,
            emergencyContact: dto.emergencyContact,
            phoneNumber: dto.phoneNumber,
            registrationDate: dto.registrationDate,
            checkInTime: dto.checkInTime,
            staff: dto.staff,
            dealer: dto.dealer,
            codeOfConductAccepted: dto.codeOfConductAccepted,
            secretCode: dto.secretCode,
            transactions: dto.transactions
        )
    }

    func toDTO() -> AttendeeDTO {
        return AttendeeDTO(
            id: self.id,
            lastModified: self.lastModified,
            active: self.active,
            badgeNumber: self.badgeNumber,
            firstName: self.firstName,
            lastName: self.lastName,
            badgeName: self.badgeName,
            membershipLevel: self.membershipLevel,
            birthday: self.birthday,
            addressLine1: self.addressLine1,
            addressLine2: self.addressLine2,
            city: self.city,
            state: self.state,
            postalCode: self.postalCode,
            shirtSize: self.shirtSize,
            emailAddress: self.emailAddress,
            emergencyContact: self.emergencyContact,
            phoneNumber: self.phoneNumber,
            registrationDate: self.registrationDate,
            checkInTime: self.checkInTime,
            staff: self.staff,
            dealer: self.dealer,
            codeOfConductAccepted: self.codeOfConductAccepted,
            secretCode: self.secretCode,
            transactions: self.transactions
        )
    }
}

// MARK: - Preview
extension Attendee {

    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: Attendee.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        for i in 0..<100 {
            let number = Double(i)

            container.mainContext.insert(
                Attendee(
                    id: UUID(),
                    convention: nil,
                    lastModified: Date(),
                    active: true,
                    badgeNumber: UInt32(i),
                    firstName: "SampleFirstName\(i)",
                    lastName: "SampleLastName\(i)",
                    badgeName: "BadgeName\(i)",
                    membershipLevel: MembershipLevel.mock(),
                    birthday: Date().addingTimeInterval(-60 * 60 * 24 * 365 * (18 + number)),  // Mock age 18+
                    addressLine1: "123 Example St",
                    addressLine2: Optional<String>.none,
                    city: "ExampleCity",
                    state: "EX",
                    postalCode: "12345",
                    shirtSize: Optional<String>.none,
                    emailAddress: "example\(i)@mockmail.com",
                    emergencyContact: Optional<String>.none,
                    phoneNumber: Optional<String>.none,
                    registrationDate: Date().addingTimeInterval(-60 * 60 * 24 * (10 + number)),  // Mock registered 10+ days ago
                    checkInTime: Optional<Date>.none,
                    staff: i % 2 == 0,  // Alternate staff status
                    dealer: i % 3 == 0,  // Alternate dealer status
                    codeOfConductAccepted: true,
                    secretCode: Optional<String>.none,
                    transactions: []
                )
            )
        }

        return container
    }
}


// MARK: - Mock
extension Attendee {
    static func mock() -> Attendee {
        return Attendee(
            id: UUID(),
            convention: .mock(),
            lastModified: Date(),
            active: true,
            badgeNumber: 1234,
            firstName: "Mock",
            lastName: "Attendee",
            badgeName: "Mocky McFunnyEars",
            membershipLevel: MembershipLevel.mock(),
            birthday: Date().addingTimeInterval(-60 * 60 * 24 * 365 * 25),  // 25 years ago
            addressLine1: "123 Mock St",
            addressLine2: "Apt 4B",
            city: "Mock City",
            state: "MO",
            postalCode: "12345",
            shirtSize: "Medium",
            emailAddress: "mock@example.com",
            emergencyContact: "Jane Doe",
            phoneNumber: "123-456-7890",
            registrationDate: Date().addingTimeInterval(-60 * 60 * 24 * 7),  // Registered 7 days ago
            checkInTime: Date().addingTimeInterval(-60 * 60 * 2),  // Checked in 2 hours ago
            staff: false,
            dealer: true,
            codeOfConductAccepted: true,
            secretCode: "MockSecret",
            transactions: [Transaction.mock()]
        )
    }
}

// MARK: - CustomStringConvertible for Debugging
extension Attendee: CustomStringConvertible {
    var description: String {
        """
        Attendee(
            id: \(id),
            convention: \(convention?.shortName ?? "nil"),
            lastModified: \(lastModified),
            active: \(active),
            badgeNumber: \(badgeNumber),
            firstName: "\(firstName)",
            lastName: "\(lastName)",
            badgeName: "\(badgeName)",
            membershipLevel: \(membershipLevel),
            birthday: \(birthday),
            addressLine1: "\(addressLine1)",
            addressLine2: "\(addressLine2 ?? "nil")",
            city: "\(city)",
            state: "\(state)",
            postalCode: "\(postalCode)",
            shirtSize: "\(shirtSize ?? "nil")",
            emailAddress: "\(emailAddress)",
            emergencyContact: "\(emergencyContact ?? "nil")",
            phoneNumber: "\(phoneNumber ?? "nil")",
            registrationDate: \(registrationDate),
            checkInTime: \(checkInTime.map {"\($0)"} ?? "nil"),
            staff: \(staff),
            dealer: \(dealer),
            codeOfConductAccepted: \(codeOfConductAccepted),
            secretCode: "\(secretCode ?? "nil")",
            transactions: \(transactions.count) total
        )
        """
    }
}
