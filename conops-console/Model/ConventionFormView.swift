//
//  ConventionFormView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

@MainActor
class ConventionFormViewModel: ObservableObject {
    @Published var longName: String = ""
    @Published var shortName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 3)
    @Published var preRegStartDate: Date = Date().addingTimeInterval(-60 * 60 * 24 * 30)
    @Published var preRegEndDate: Date = Date().addingTimeInterval(-60 * 60 * 24 * 5)
    @Published var registrationOpen: Bool = true
    @Published var contactEmailAddress: String = ""
    @Published var dealersDenPresent: Bool = false
    @Published var minBadgeNumber: UInt32 = 100
    @Published var mailTemplates: [String: String] = ["welcome": "Welcome to MockCon!"]

    func toConvention() -> Convention {
        Convention(
            id: UUID(),
            active: true,
            longName: longName,
            shortName: shortName,
            startDate: startDate,
            endDate: endDate,
            preRegStartDate: preRegStartDate,
            preRegEndDate: preRegEndDate,
            registrationOpen: registrationOpen,
            headerExtras: nil,
            footerExtras: nil,
            contactEmailAddress: contactEmailAddress,
            slackWebHook: nil,
            postmarkServerToken: nil,
            twilioAccountSID: nil,
            twilioAuthToken: nil,
            twilioOutgoingNumber: nil,
            compareTo: nil,
            minBadgeNumber: minBadgeNumber,
            dealersDenPresent: dealersDenPresent,
            dealersDenRegText: nil,
            paypalAPIUserName: nil,
            paypalAPIPassword: nil,
            paypalAPISignature: nil,
            membershipLevels: [],
            shirtSizes: [],
            mailTemplates: mailTemplates
        )
    }
}
