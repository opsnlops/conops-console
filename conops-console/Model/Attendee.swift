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
    var id: AttendeeIdentifier
    var lastModified: Date
    var active: Bool
    var badgeNumber: UInt32
    var firstName: String
    var lastName: String
    var badgeName: String
    var membershipLevel: MembershipLevel
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
