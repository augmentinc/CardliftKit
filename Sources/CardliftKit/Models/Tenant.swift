//
//  Tenant.swift
//  CardliftKit
//
//  Created by Ray Nirola on 11/01/25.
//

import Foundation


struct Tenant: Codable, Identifiable {
    let id, slug, name, bundleIdentifier: String
    let appStoreLink: String
    let cardImage: String
    let foregroundColor, backgroundColor: ConfigColor
    let buttonRadius: Double
    let upsellLabel, title: String
    let features: [String]
}

struct ConfigColor: Codable {
    let r, g, b: Double
}
