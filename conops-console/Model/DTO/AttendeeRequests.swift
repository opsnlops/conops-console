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

struct AttendeeCreateRequest: Encodable {
    let firstName: String
    let lastName: String
    let badgeName: String
    let membershipLevelId: MembershipLevelIdentifier
    let birthday: Date
    let emailAddress: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let postalCode: String
    let phoneNumber: String?
    let emergencyContact: String?
    let shirtSize: String?
    let referral: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case badgeName = "badge_name"
        case membershipLevelId = "membership_level_id"
        case birthday
        case emailAddress = "email_address"
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city
        case state
        case postalCode = "postal_code"
        case phoneNumber = "phone_number"
        case emergencyContact = "emergency_contact"
        case shirtSize = "shirt_size"
        case referral
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(badgeName, forKey: .badgeName)
        try container.encode(membershipLevelId, forKey: .membershipLevelId)
        try container.encode(DateOnly(birthday), forKey: .birthday)
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(addressLine1, forKey: .addressLine1)
        try container.encode(addressLine2, forKey: .addressLine2)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(emergencyContact, forKey: .emergencyContact)
        try container.encode(shirtSize, forKey: .shirtSize)
        try container.encode(referral, forKey: .referral)
    }
}

struct AttendeeUpdateRequest: Encodable {
    let badgeNumber: UInt32
    let firstName: String
    let lastName: String
    let badgeName: String
    let membershipLevelId: MembershipLevelIdentifier
    let birthday: Date
    let emailAddress: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let postalCode: String
    let phoneNumber: String?
    let emergencyContact: String?
    let shirtSize: String?
    let referral: String?
    let staff: Bool
    let active: Bool
    let checkInTime: Date?
    let reason: String
    let notifyAttendee: Bool

    enum CodingKeys: String, CodingKey {
        case badgeNumber = "badge_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case badgeName = "badge_name"
        case membershipLevelId = "membership_level_id"
        case birthday
        case emailAddress = "email_address"
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city
        case state
        case postalCode = "postal_code"
        case phoneNumber = "phone_number"
        case emergencyContact = "emergency_contact"
        case shirtSize = "shirt_size"
        case referral
        case staff
        case active
        case checkInTime = "check_in_time"
        case reason
        case notifyAttendee = "notify_attendee"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(badgeNumber, forKey: .badgeNumber)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(badgeName, forKey: .badgeName)
        try container.encode(membershipLevelId, forKey: .membershipLevelId)
        try container.encode(DateOnly(birthday), forKey: .birthday)
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(addressLine1, forKey: .addressLine1)
        try container.encode(addressLine2, forKey: .addressLine2)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(emergencyContact, forKey: .emergencyContact)
        try container.encode(shirtSize, forKey: .shirtSize)
        try container.encode(referral, forKey: .referral)
        try container.encode(staff, forKey: .staff)
        try container.encode(active, forKey: .active)
        try container.encode(checkInTime, forKey: .checkInTime)
        try container.encode(reason, forKey: .reason)
        try container.encode(notifyAttendee, forKey: .notifyAttendee)
    }
}

struct TransactionCreateRequest: Encodable {
    let amount: Float
    let typeCode: Int
    let notes: String

    enum CodingKeys: String, CodingKey {
        case amount
        case typeCode = "type_code"
        case notes
    }
}

struct AttendeeNotifyRequest: Encodable {
    let reason: String
}

struct AttendeeWelcomeRequest: Encodable {
    let isVolunteer: Bool
    let isDealer: Bool

    enum CodingKeys: String, CodingKey {
        case isVolunteer = "is_volunteer"
        case isDealer = "is_dealer"
    }
}

struct PrintBadgeRequest: Encodable {
    let printerName: String

    enum CodingKeys: String, CodingKey {
        case printerName = "printer_name"
    }
}
