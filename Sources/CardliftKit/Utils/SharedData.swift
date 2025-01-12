//import Foundation
//import Security
//
///**
// An enumeration that represents shared data within the CardliftKit module.
// This enum is used to manage and access shared data across different parts of the application securely using Keychain.
// */
//enum SharedData {
//    private static var serviceIdentifier = "com.augument.cardlift.sharedData"
//
//    /**
//     Configures the shared data with the specified service identifier.
//     - Parameter serviceIdentifier: A string that identifies the Keychain service to be configured.
//     */
//    public static func configure(serviceIdentifier: String) {
//        self.serviceIdentifier = serviceIdentifier
//    }
//
//    /**
//     An enumeration representing keys used for shared data.
//     - `cardMetaDataKey`: A key for card metadata.
//     This enumeration provides a computed property `key` that returns the raw value of the case.
//     */
//    enum Keys: String {
//        case cardMetaDataKey
//        var key: String { rawValue }
//    }
//
//    /**
//     A static variable that holds optional card metadata.
//     This variable can be used to access or modify the metadata associated with a card.
//    */
//    static var cardMetaData: CardMetaData? {
//        get {
//            NSLog("Debug: Inside SharedData.cardMetaData, GET")
//            guard let data = getKeychainData(for: Keys.cardMetaDataKey.key) else {
//                NSLog("Debug: CardMetadata not found")
//                return nil
//            }
//            NSLog("Debug: Inside SharedData.cardMetaData, GET, data: \(data)")
//            return try? JSONDecoder().decode(CardMetaData.self, from: data)
//        }
//        set {
//            if let newValue = newValue,
//               let data = try? JSONEncoder().encode(newValue) {
//                setKeychainData(data, for: Keys.cardMetaDataKey.key)
//            } else {
//                removeKeychainData(for: Keys.cardMetaDataKey.key)
//            }
//        }
//    }
//
//    /**
//     Clears the shared data.
//     This method is used to reset or clear any data stored in the Keychain.
//     It can be useful for scenarios where you need to ensure that the shared data is in a clean state.
//     */
//    public static func clear() {
//        removeKeychainData(for: Keys.cardMetaDataKey.key)
//    }
//
//    /**
//     Retrieves data from the keychain for a given key.
//     This method constructs a query to search for a generic password item in the keychain
//     associated with the specified key. If the item is found, the associated data is returned.
//     - Parameter key: The key for which to retrieve the data from the keychain.
//     - Returns: The data associated with the specified key, or `nil` if the item is not found or an error occurs.
//     */
//    private static func getKeychainData(for key: String) -> Data? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: serviceIdentifier,
//            kSecAttrAccount as String: key,
//            kSecReturnData as String: true
//        ]
//
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        NSLog("Debug: Keychain retrieval query: \(query)")
//        NSLog("Debug: Keychain retrieval result: \(String(describing: result))")
//        NSLog("Debug: Keychain retrieval status: \(status)")
//
//        guard status == errSecSuccess else { return nil }
//        return result as? Data
//    }
//
//    /**
//     Stores the given data in the keychain for the specified key.
//     - Parameters:
//     - data: The data to be stored in the keychain.
//     - key: The key under which the data should be stored.
//     - Note: If the key already exists in the keychain, the existing data will be updated with the new data.
//     */
//    private static func setKeychainData(_ data: Data, for key: String) {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: serviceIdentifier,
//            kSecAttrAccount as String: key
//        ]
//
//        let attributes: [String: Any] = [
//            kSecValueData as String: data
//        ]
//
//        let status = SecItemAdd(query as CFDictionary, nil)
//
//        if status == errSecDuplicateItem {
//            SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
//        }
//    }
//
//    /**
//     Removes the keychain data associated with the specified key.
//     This method constructs a query dictionary with the provided key and
//     predefined service identifier, and then deletes the corresponding
//     keychain item using `SecItemDelete`.
//     - Parameter key: The key for which the keychain data should be removed.
//     */
//    private static func removeKeychainData(for key: String) {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: serviceIdentifier,
//            kSecAttrAccount as String: key
//        ]
//
//        SecItemDelete(query as CFDictionary)
//    }
//}

// SharedData.swift

import Foundation

/// An enumeration that represents shared data within the CardliftKit module.
/// This enum is used to manage and access shared data across different parts of the application.
enum SharedData {
    private static var groupIdentifier = "group.com.augument.cardlift.sharedData"

    /**
     Configures the shared data with the specified group identifier.
     
     - Parameter groupIdentifier: A string that identifies the group to be configured.
     */
    public static func configure(serviceIdentifier: String) {
        self.groupIdentifier = serviceIdentifier
        defaultsGroup = UserDefaults(suiteName: groupIdentifier)
    }

    /// A static variable that holds a reference to the `UserDefaults` instance for the specified suite name.
    /// The suite name is defined by the `groupIdentifier`.
    /// This variable is private for setting but can be accessed publicly.
    private(set) static var defaultsGroup = UserDefaults(suiteName: groupIdentifier)

    enum Keys: String {
        case cardMetaDataKey
        var key: String { rawValue }
    }

    /// A static variable that holds optional card metadata.
    /// This variable can be used to access or modify the metadata associated with a card.
    static var cardMetaData: CardMetaData? {
        get {
            if let data = defaultsGroup?.data(forKey: Keys.cardMetaDataKey.key) {
                return try? JSONDecoder().decode(CardMetaData.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue)
            {
                defaultsGroup?.set(data, forKey: Keys.cardMetaDataKey.key)
            } else {
                defaultsGroup?.removeObject(forKey: Keys.cardMetaDataKey.key)
            }
        }
    }

    /// Clears the shared data.
    ///
    /// This method is used to reset or clear any data stored in the shared data structure.
    /// It can be useful for scenarios where you need to ensure that the shared data is in a clean state.
    public static func clear() {
        defaultsGroup?.removeObject(forKey: Keys.cardMetaDataKey.key)
    }
}
