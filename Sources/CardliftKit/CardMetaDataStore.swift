//
//  CardMetaDataStore.swift
//  CardliftKit
//
//  Created by Sriram Hariharan on 12/20/24.
//

/// A store for saving and retrieving `CardMetaData` objects.
enum CardMetaDataStore {
    /// Saves the given `CardMetaData` to the shared user defaults.
    public static func saveCardMetaData(_ metaData: CardMetaData) {
        SharedData.cardMetaData = metaData
    }

    /// Retrieves the currently saved `CardMetaData`, if any.
    public static func getCardMetaData() -> CardMetaData? {
        return SharedData.cardMetaData
    }

    /// Clears the currently saved `CardMetaData`.
    public static func clearCardMetaData() {
        SharedData.clear()
    }
}
