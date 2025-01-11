//
//  UpsellButtonConfig.swift
//  CardliftKit
//
//  Created by Ray Nirola on 11/01/25.
//
import SwiftUI

/**
 A configuration for the upsell button.
 - Parameter text: The button text.
 - Parameter backgroundColor: The button background color.
 - Parameter foregroundColor: The button text color.
 - Parameter cornerRadius: The button corner radius.
 */
public struct UpsellButtonConfig {
    var text: String
    var backgroundColor: Color
    var foregroundColor: Color

    public init(
        text: String,
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 8
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
}
