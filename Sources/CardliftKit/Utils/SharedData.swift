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
    public static func configure(groupIdentifier: String) {
        self.groupIdentifier = groupIdentifier
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
