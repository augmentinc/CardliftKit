//
//  CardMetaDataParser.swift
//  cardlift-mobile
//
//  Created by Sriram Hariharan on 12/7/24.
//

import Foundation

/// A structure that holds the expiry details of a card.
struct ExpiryDetails {
    public let cardExpirationDate: String
    public let cardExpirationDateFull: String
    public let cardExpirationDateFullNoSlash: String
    public let cardExpirationDateNoSlash: String
    public let cardExpirationYear: String
    public let cardExpirationYearShort: String
    public let cardExpirationMonthFull: String
    public let cardExpirationMonthShort: String
    public let cardExpirationMonth: String
}

/// An enumeration that provides functionality for parsing card metadata.
/// This enum contains methods and properties that help in extracting and
/// interpreting metadata associated with cards.
enum CardMetaDataParser {
    /// Computes the CardMetaData based on the provided UserFormData
    public static func computeCardMetaData(from data: CardliftCardFormData) -> CardMetaData? {
        guard let expiryDetails = computeExpiryDate(from: data.expiry) else { return nil }

        let cardNickname = "\(data.cardNumber.suffix(4)) \(Int.random(in: 1000...9999))"
        let fullName = "\(data.firstName) \(data.lastName)"

        return CardMetaData(
            cardNumber: cleanCardNumber(data.cardNumber),
            cardExpirationMonth: expiryDetails.cardExpirationMonth,
            cardExpirationMonthShort: expiryDetails.cardExpirationMonthShort,
            cardExpirationMonthFull: expiryDetails.cardExpirationMonthFull,
            cardExpirationYearShort: expiryDetails.cardExpirationYearShort,
            cardExpirationYear: expiryDetails.cardExpirationYear,
            cardExpirationDateNoSlash: expiryDetails.cardExpirationDateNoSlash,
            cardExpirationDateFull: expiryDetails.cardExpirationDateFull,
            cardExpirationDateFullNoSlash: expiryDetails.cardExpirationDateFullNoSlash,
            cardExpirationDate: expiryDetails.cardExpirationDate,
            cardCvc: data.cvv,
            cardType: data.cardType,
            title: "Mr.",  // Default title
            name: fullName,
            firstName: data.firstName,
            lastName: data.lastName,
            address: data.address,
            address2: data.address2,
            city: data.city,
            state: data.state,
            stateFull: data.state,  // Assuming `state` is used for both
            country: data.country,
            countryFull: data.countryFull,
            zip: data.zip,
            phone: data.phone,
            email: data.email,
            nickname: cardNickname
        )
    }

    /// Parses and formats the expiry date into various formats
    private static func computeExpiryDate(from expiry: String) -> ExpiryDetails? {
        let components = expiry.split(separator: "/")
        guard components.count == 2,
            let month = Int(components[0]),
            let year = Int(components[1])
        else { return nil }

        let monthName = getMonthName(for: month)
        return ExpiryDetails(
            cardExpirationDate: expiry,
            cardExpirationDateFull: "\(month)/20\(year)",
            cardExpirationDateFullNoSlash: "\(month)20\(year)",
            cardExpirationDateNoSlash: "\(month)\(year)",
            cardExpirationYear: "20\(year)",
            cardExpirationYearShort: "\(year)",
            cardExpirationMonthFull: monthName,
            cardExpirationMonthShort: String(monthName.prefix(3)),
            cardExpirationMonth: "\(month)"
        )
    }

    /// Cleans the card number by removing all spaces
    private static func cleanCardNumber(_ value: String) -> String {
        value.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }

    /// Returns the full month name for a given numeric month
    private static func getMonthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let dateComponents = DateComponents(calendar: .current, month: month)
        return formatter.string(from: dateComponents.date ?? Date())
    }
}
