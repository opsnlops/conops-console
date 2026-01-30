//
//  ConventionDTO.swift
//  Conops Console
//
//  Created by April White on 1/5/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ConventionDTO: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: ConventionIdentifier
    let lastModified: Date
    let active: Bool
    let longName: String
    let shortName: String
    let startDate: Date
    let endDate: Date
    let preRegStartDate: Date
    let preRegEndDate: Date
    let registrationOpen: Bool
    let headerExtras: String?
    let headerGraphic: String?
    let styleSheet: String?
    let footerExtras: String?
    let badgeClass: String?
    let contactEmailAddress: String?
    let replicationMode: String?
    let slackWebHook: String?
    let postmarkServerToken: String?
    let messagingServiceEndpoint: String?
    let messagingServiceApiKey: String?
    let twilioAccountSID: String?
    let twilioAuthToken: String?
    let twilioOutgoingNumber: String?
    let compareTo: ConventionIdentifier?
    let minBadgeNumber: UInt32
    let dealersDenPresent: Bool
    let dealersDenRegText: String?
    let paypalAPIUserName: String?
    let paypalAPIPassword: String?
    let paypalAPISignature: String?
    let membershipLevels: [MembershipLevel]
    let shirtSizes: [ShirtSize]
    let mailTemplates: [String: String]

    enum CodingKeys: String, CodingKey {
        case id
        case lastModified = "last_modified"
        case active
        case longName = "long_name"
        case shortName = "short_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case preRegStartDate = "pre_reg_start_date"
        case preRegEndDate = "pre_reg_end_date"
        case registrationOpen = "registration_open"
        case headerExtras = "header_extras"
        case headerGraphic = "header_graphic"
        case styleSheet = "style_sheet"
        case footerExtras = "footer_extras"
        case badgeClass = "badge_class"
        case contactEmailAddress = "contact_email_address"
        case replicationMode = "replication_mode"
        case slackWebHook = "slack_web_hook"
        case postmarkServerToken = "postmark_server_token"
        case messagingServiceEndpoint = "messaging_service_endpoint"
        case messagingServiceApiKey = "messaging_service_api_key"
        case twilioAccountSID = "twilio_account_sid"
        case twilioAuthToken = "twilio_auth_token"
        case twilioOutgoingNumber = "twilio_outgoing_number"
        case compareTo = "compare_to"
        case minBadgeNumber = "min_badge_number"
        case dealersDenPresent = "dealers_den_present"
        case dealersDenRegText = "dealers_den_reg_text"
        case paypalAPIUserName = "paypal_api_user_name"
        case paypalAPIPassword = "paypal_api_password"
        case paypalAPISignature = "paypal_api_signature"
        case membershipLevels = "membership_levels"
        case shirtSizes = "shirt_sizes"
        case mailTemplates = "mail_templates"
    }

    static func < (lhs: ConventionDTO, rhs: ConventionDTO) -> Bool {
        lhs.shortName.localizedCaseInsensitiveCompare(rhs.shortName) == .orderedAscending
    }

    static func mock() -> ConventionDTO {
        ConventionDTO(
            id: ConventionIdentifier(),
            lastModified: Date(),
            active: true,
            longName: "Mock Convention",
            shortName: "MockCon",
            startDate: Date(),
            endDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
            preRegStartDate: Date().addingTimeInterval(-60 * 60 * 24 * 30),
            preRegEndDate: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            registrationOpen: true,
            headerExtras: "Mock Header",
            headerGraphic: "mock-header.png",
            styleSheet: "mock-style.css",
            footerExtras: "Mock Footer",
            badgeClass: "standard",
            contactEmailAddress: "mock@convention.com",
            replicationMode: "primary",
            slackWebHook: "https://mock.slack.webhook",
            postmarkServerToken: "mock-postmark-token",
            messagingServiceEndpoint: "https://mock.messaging.service",
            messagingServiceApiKey: "mock-messaging-key",
            twilioAccountSID: "mock-sid",
            twilioAuthToken: "mock-auth-token",
            twilioOutgoingNumber: "+1234567890",
            compareTo: nil,
            minBadgeNumber: 100,
            dealersDenPresent: false,
            dealersDenRegText: nil,
            paypalAPIUserName: nil,
            paypalAPIPassword: nil,
            paypalAPISignature: nil,
            membershipLevels: [MembershipLevel.mock()],
            shirtSizes: [ShirtSize.mock()],
            mailTemplates: ["welcome": "Welcome to MockCon!"]
        )
    }
}
