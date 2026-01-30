import Foundation

struct PublicConventionDTO: Decodable {
    let shortName: String
    let longName: String

    enum CodingKeys: String, CodingKey {
        case shortName = "short_name"
        case longName = "long_name"
    }
}
