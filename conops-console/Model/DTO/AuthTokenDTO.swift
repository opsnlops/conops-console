import Foundation

struct AuthTokenRequest: Encodable {
    let conventionShortName: String
    let username: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case conventionShortName = "convention_short_name"
        case username
        case password
    }
}

struct AuthTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
