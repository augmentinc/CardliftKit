//
//  Tenant.swift
//  CardliftKit
//
//  Created by Ray Nirola on 11/01/25.
//

import Foundation


struct Tenant: Codable {
    let id, slug: String
    let name, card: String?
    let buttonColor, buttonBackground: String
    let autofillBackgroundColor, autofillTextColor: String

    enum CodingKeys: String, CodingKey {
        case id, slug, name, card, buttonColor, buttonBackground, autofillBackgroundColor, autofillTextColor
    }
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
