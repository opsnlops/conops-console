import Foundation

struct DeviceTokenRegistrationRequest: Encodable, Sendable {
    let deviceToken: String
    let platform: String
    let deviceName: String?

    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case platform
        case deviceName = "device_name"
    }
}

struct DeviceTokenUnregistrationRequest: Encodable, Sendable {
    let deviceToken: String

    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
    }
}
