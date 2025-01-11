//
//  UpsellButtonConfig.swift
//  CardliftKit
//
//  Created by Ray Nirola on 11/01/25.
//
import SwiftUI

/**
 A configuration for the upsell button.
 Keeping it as minimalist as possible to reduce friction
 - Parameter backgroundColor: The button background color.
 - Parameter foregroundColor: The button text color.
 */
public struct UpsellButtonConfig {
    var backgroundColor: Color
    var foregroundColor: Color

    public init(
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
}
