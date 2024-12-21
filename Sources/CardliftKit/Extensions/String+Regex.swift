//
//  String+Regex.swift
//  cardlift-mobile
//
//  Created by Sriram Hariharan on 12/6/24.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        range(of: regex, options: .regularExpression) != nil
    }
}
