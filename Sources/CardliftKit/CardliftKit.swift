import Foundation

/// The main entry point for the CardliftKit SDK.
/// All public APIs are exposed here, so consumers only import and interact with `CardliftKit`.
public enum CardliftKit {
    // MARK: - Configuration

    /// Sets the shared data group identifier for storing and retrieving card data.
    /// - Parameter sharedDataGroupIdentifier: The App Group ID (e.g., "group.com.mycompany.myapp").
    public static func configure(sharedDataGroupIdentifier: String) {
        SharedData.configure(groupIdentifier: sharedDataGroupIdentifier)
    }

    /// Registers web extension message handlers, if you have some:
    public static func setup(router: WebExtensionMessageRouter) {
        router.registerHandler(GetCardMetaDataHandler())
        // Other handlers here...
    }

    // MARK: - CardMetaData Access

    /// Saves the provided CardMetaData to the shared data store.
    public static func saveCardMetaData(_ metaData: CardMetaData) {
        SharedData.cardMetaData = metaData
    }

    /// Retrieves the current CardMetaData from the shared data store, if any.
    public static func getCardMetaData() -> CardMetaData? {
        return SharedData.cardMetaData
    }

    /// Clears the stored CardMetaData.
    public static func clearCardMetaData() {
        SharedData.clear()
    }

    // MARK: - Validation

    /// Validates all fields in the provided `CardliftCardFormData` and returns a dictionary of errors.
    /// - Parameter formData: The form data to validate.
    /// - Returns: A dictionary mapping field names to error messages.
    public static func validateAllFields(_ formData: CardliftCardFormData) -> [String: String] {
        var errors: [String: String] = [:]
        for field in CardliftCardFormData.allFields {
            CardliftCardFormData.validateField(field, in: formData, errors: &errors)
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
        CardliftCardFormData.validateField(field, in: formData, errors: &errors)
    }

    // MARK: - CardMetaData Parsing

    /// Computes `CardMetaData` from the provided `CardliftCardFormData`.
    /// - Parameter formData: The input form data.
    /// - Returns: The computed `CardMetaData`, or `nil` if the form data is invalid.
    public static func computeCardMetaData(from formData: CardliftCardFormData) -> CardMetaData? {
        return CardMetaDataParser.computeCardMetaData(from: formData)
    }
}
