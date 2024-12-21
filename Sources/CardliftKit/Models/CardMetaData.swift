//
//  CardMetaData.swift
//  cardlift-mobile
//
//  Created by Sriram Hariharan on 12/6/24.
//

/**
 
 */
public struct CardMetaData: Codable {
    public let cardNumber: String
    public let cardExpirationMonth: String
    public let cardExpirationMonthShort: String
    public let cardExpirationMonthFull: String
    public let cardExpirationYearShort: String
    public let cardExpirationYear: String
    public let cardExpirationDateNoSlash: String
    public let cardExpirationDateFull: String
    public let cardExpirationDateFullNoSlash: String
    public let cardExpirationDate: String
    public let cardCvc: String
    public let cardType: String
    public let title: String
    public let name: String
    public let firstName: String
    public let lastName: String
    public let address: String
    public let address2: String
    public let city: String
    public let state: String
    public let stateFull: String
    public let country: String
    public let countryFull: String
    public let zip: String
    public let phone: String
    public let email: String
    public let nickname: String
}
