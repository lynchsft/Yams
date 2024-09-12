//
//  Anchor.swift
//  Yams
//
//  Created by Adora Lynch on 8/9/24.
//  Copyright (c) 2024 Yams. All rights reserved.

import Foundation

public final class Anchor: RawRepresentable, ExpressibleByStringLiteral, Codable, Hashable {
    
    public static let permittedCharacters = CharacterSet.lowercaseLetters
                                                .union(.uppercaseLetters)
                                                .union(.decimalDigits)
                                                .union(.init(charactersIn: "-_"))
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        assertIs_cyamlAlpha(rawValue)
    }
    
    public init(stringLiteral value: String) {
        rawValue = value
        assertIs_cyamlAlpha(rawValue)
    }
}

extension Anchor: CustomStringConvertible {
    public var description: String { rawValue }
}

private func assertIs_cyamlAlpha(_ string: String) {
    assert(is_cyamlAlpha(string), "Anchors may consist only of numerals, a-z english (ASCII) letters, uppercase A-Z lang/en-* letters, underscore (_) and regular-dash (-).\n\(Anchor.permittedCharacters)\nInvalid anchor: \(string)")
}

private func is_cyamlAlpha(_ string: String) -> Bool {
    Anchor.permittedCharacters.isSuperset(of: .init(charactersIn: string))
}
