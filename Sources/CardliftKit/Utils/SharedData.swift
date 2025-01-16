import Foundation
import Security

/**
 An enumeration that represents shared data within the CardliftKit module.
 This enum is used to manage and access shared data across different parts of the application securely using Keychain.
 */
enum SharedData {
    public static var serviceIdentifier = "demo.cardlift.kit.shared"

    /**
     Configures the shared data with the specified service identifier.
     - Parameter serviceIdentifier: A string that identifies the Keychain service to be configured.
     */
    public static func configure(serviceIdentifier: String) {
        self.serviceIdentifier = serviceIdentifier
    }

    /**
     An enumeration representing keys used for shared data.
     - `cardMetaDataKey`: A key for card metadata.
     This enumeration provides a computed property `key` that returns the raw value of the case.
     */
    enum Keys: String {
        case cardMetaDataKey
        case accountInfoKey
        var key: String { rawValue }
    }

    /**
     A static variable that holds optional card metadata.
     This variable can be used to access or modify the metadata associated with a card.
    */
    static var cardMetaData: CardMetaData? {
        get {
            guard let data = getKeychainData(for: Keys.cardMetaDataKey.key) else {
                return nil
            }
            return try? JSONDecoder().decode(CardMetaData.self, from: data)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                setKeychainData(data, for: Keys.cardMetaDataKey.key)
            } else {
                removeKeychainData(for: Keys.cardMetaDataKey.key)
            }
        }
    }
    
    static var accountInfo: AccountInfo? {
        get {
            guard let data = getKeychainData(for: "accountInfo") else {
                return nil
            }
            return try? JSONDecoder().decode(AccountInfo.self, from: data)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                setKeychainData(data, for: Keys.accountInfoKey.key)
            } else {
                removeKeychainData(for: Keys.cardMetaDataKey.key)
            }
        }
    }

    /**
     Clears the shared data.
     This method is used to reset or clear any data stored in the Keychain.
     It can be useful for scenarios where you need to ensure that the shared data is in a clean state.
     */
    public static func clear() {
        removeKeychainData(for: Keys.cardMetaDataKey.key)
    }

    /**
     Retrieves data from the keychain for a given key.
     This method constructs a query to search for a generic password item in the keychain
     associated with the specified key. If the item is found, the associated data is returned.
     - Parameter key: The key for which to retrieve the data from the keychain.
     - Returns: The data associated with the specified key, or `nil` if the item is not found or an error occurs.
     */
    private static func getKeychainData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /**
     Stores the given data in the keychain for the specified key.
     - Parameters:
     - data: The data to be stored in the keychain.
     - key: The key under which the data should be stored.
     - Note: If the key already exists in the keychain, the existing data will be updated with the new data.
     */
    private static func setKeychainData(_ data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
    }

    /**
     Removes the keychain data associated with the specified key.
     This method constructs a query dictionary with the provided key and
     predefined service identifier, and then deletes the corresponding
     keychain item using `SecItemDelete`.
     - Parameter key: The key for which the keychain data should be removed.
     */
    private static func removeKeychainData(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
