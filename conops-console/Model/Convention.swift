//
//  Convention.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData

/// This struct (or class) is your local SwiftData model.
/// It's intentionally separate from the DTO.
@Model
class Convention {
    // SwiftData typically wants `var` so it can mutate these properties
    var id: UUID
    var lastModified: Date
    var active: Bool
    var longName: String
    var shortName: String
    var startDate: Date
    var endDate: Date
    var preRegStartDate: Date
    var preRegEndDate: Date
    var registrationOpen: Bool
    var headerExtras: String?
    var footerExtras: String?
    var contactEmailAddress: String?
    var slackWebHook: String?
    var postmarkServerToken: String?
    var twilioAccountSID: String?
    var twilioAuthToken: String?
    var twilioOutgoingNumber: String?
    var compareTo: UUID?
    var minBadgeNumber: UInt32
    var dealersDenPresent: Bool
    var dealersDenRegText: String?
    var paypalAPIUserName: String?
    var paypalAPIPassword: String?
    var paypalAPISignature: String?

    // For membershipLevels, shirtSizes, and mailTemplates,
    // SwiftData might require special handling.
    // For now, let's just keep them as direct properties
    // (You might convert them to separate @Model references or transformable data).
    var membershipLevels: [MembershipLevel]
    var shirtSizes: [ShirtSize]
    var mailTemplates: [String: String]

    // MARK: - Simple init for SwiftData
    // Swift will auto-generate a memberwise init,
    // but if you want a custom one, you can define it.

    // MARK: - Converting from DTO
    init(dto: ConventionDTO) {
        self.id = dto.id
        self.lastModified = dto.lastModified
        self.active = dto.active
        self.longName = dto.longName
        self.shortName = dto.shortName
        self.startDate = dto.startDate
        self.endDate = dto.endDate
        self.preRegStartDate = dto.preRegStartDate
        self.preRegEndDate = dto.preRegEndDate
        self.registrationOpen = dto.registrationOpen
        self.headerExtras = dto.headerExtras
        self.footerExtras = dto.footerExtras
        self.contactEmailAddress = dto.contactEmailAddress
        self.slackWebHook = dto.slackWebHook
        self.postmarkServerToken = dto.postmarkServerToken
        self.twilioAccountSID = dto.twilioAccountSID
        self.twilioAuthToken = dto.twilioAuthToken
        self.twilioOutgoingNumber = dto.twilioOutgoingNumber
        self.compareTo = dto.compareTo
        self.minBadgeNumber = dto.minBadgeNumber
        self.dealersDenPresent = dto.dealersDenPresent
        self.dealersDenRegText = dto.dealersDenRegText
        self.paypalAPIUserName = dto.paypalAPIUserName
        self.paypalAPIPassword = dto.paypalAPIPassword
        self.paypalAPISignature = dto.paypalAPISignature
        self.membershipLevels = dto.membershipLevels
        self.shirtSizes = dto.shirtSizes
        self.mailTemplates = dto.mailTemplates
    }
}
