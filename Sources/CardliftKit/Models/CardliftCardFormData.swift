import Foundation

public struct CardliftCardFormData: Codable {
    public init() {}

    // MARK: - Properties

    public var firstName: String = ""
    public var lastName: String = ""
    public var phone: String = ""
    public var email: String = ""
    public var address: String = ""
    public var address2: String = ""
    public var city: String = ""
    public var state: String = ""
    public var zip: String = ""
    public var country: String = ""
    public var countryFull: String = ""
    public var cardNumber: String = ""
    public var expiry: String = ""
    public var cvv: String = ""
    public var cardType: String = CardType.visa.rawValue

    // MARK: - All Fields

    /// A convenience list of all fields you might want to validate.
    public static let allFields: [String] = [
        "firstName", "lastName", "phone", "email", "address", "city", "state",
        "zip", "country", "countryFull", "cardNumber", "expiry", "cvv", "cardType",
    ]

    // MARK: - Validation Entry Points

    /// Validates *all* fields in the given `CardliftCardFormData`, returning a dictionary of errors.
    /// - Returns: A `[String: String]` mapping field names to error messages, or empty strings if no error.
    public static func validateAllFields(_ formData: CardliftCardFormData) -> [String: String] {
        var errors: [String: String] = [:]
        for field in allFields {
            validateField(field, in: formData, errors: &errors)
        }
        return errors
    }

    /// Validates a single field in `CardliftCardFormData` and updates an `errors` dictionary in-place.
    /// - Parameters:
    ///   - field: The field name to validate (e.g. `"firstName"`, `"phone"`).
    ///   - formData: The data being validated.
    ///   - errors: An inout dictionary of errors to update.
    public static func validateField(_ field: String,
                                     in formData: CardliftCardFormData,
                                     errors: inout [String: String])
    {
        switch field {
            case "firstName":
                errors["firstName"] = formData.firstName.isEmpty ? "First name is required" : nil

            case "lastName":
                errors["lastName"] = formData.lastName.isEmpty ? "Last name is required" : nil

            case "phone":
                if formData.phone.count != 10 || !formData.phone.allSatisfy(\.isNumber) {
                    errors["phone"] = "Phone must be 10 digits"
                } else {
                    errors["phone"] = nil
                }

            case "email":
                if formData.email.isEmpty || !formData.email.contains("@") {
                    errors["email"] = "Valid email is required"
                } else {
                    errors["email"] = nil
                }

            case "address":
                errors["address"] = formData.address.isEmpty ? "Address is required" : nil

            case "city":
                errors["city"] = formData.city.isEmpty ? "City is required" : nil

            case "state":
                errors["state"] = formData.state.isEmpty ? "State is required" : nil

            case "zip":
                if formData.zip.count != 5 || !formData.zip.allSatisfy(\.isNumber) {
                    errors["zip"] = "ZIP must be 5 digits"
                } else {
                    errors["zip"] = nil
                }

            case "country":
                errors["country"] = formData.country.isEmpty ? "Country is required" : nil

            case "countryFull":
                errors["countryFull"] = formData.countryFull.isEmpty ? "Country full name is required" : nil

            case "cardNumber":
                let cleaned = formData.cardNumber.replacingOccurrences(of: " ", with: "")
                if cleaned.count != 16 || !cleaned.allSatisfy(\.isNumber) {
                    errors["cardNumber"] = "Card number must be 16 digits"
                } else {
                    errors["cardNumber"] = nil
                }

            case "expiry":
                let regex = #"^\d{2}/\d{2}$"#
                if !formData.expiry.matches(regex) {
                    errors["expiry"] = "Expiry must be in MM/YY format"
                } else {
                    errors["expiry"] = nil
                }

            case "cvv":
                errors["cvv"] = (formData.cvv.count == 3 && formData.cvv.allSatisfy(\.isNumber))
                    ? nil : "CVC must be 3 digits"

            case "cardType":
                errors["cardType"] = formData.cardType.isEmpty ? "Card type is required" : nil

            default:
                // No-op if field name doesn't match our known fields
                break
        }
    }
}

// MARK: - Supporting Types

public enum CardType: String, CaseIterable, Codable {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case american = "AMERICAN"
    case discover = "DISCOVER"
}
