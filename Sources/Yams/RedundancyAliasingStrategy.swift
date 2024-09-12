//
//  RedundancyAliasingStrategy.swift
//  Yams
//
//  Created by Adora Lynch on 8/15/24.
//  Copyright (c) 2024 Yams. All rights reserved.
//

import Foundation

public enum RedundancyAliasingOutcome {
    case anchor(Anchor)
    case alias(Anchor)
    case none
}
public protocol RedundancyAliasingStrategy: AnyObject {
    
    func alias(for encodable: any Encodable) throws -> RedundancyAliasingOutcome
    
    func releaseAnchorReferences() throws
}

public class HashableAliasingStrategy: RedundancyAliasingStrategy {
    private var hashesToAliases: [AnyHashable: Anchor] = [:]
    
    let uniqueAliasProvider = UniqueAliasProvider()
    
    public init() {}
    
    public func alias(for encodable: any Encodable) throws -> RedundancyAliasingOutcome {
        guard let hashable = encodable as? any Hashable & Encodable else {
            return .none
        }
        return try alias(for: hashable)
    }
    
    private func alias(for hashable: any Hashable & Encodable) throws -> RedundancyAliasingOutcome {
        let anyHashable = AnyHashable(hashable)
        if let existing = hashesToAliases[anyHashable] {
//            print("Recovering \(existing) #\(anyHashable.hashValue) for \(String(describing: hashable))")
            return .alias(existing)
        } else {
            let newAlias = uniqueAliasProvider.uniqueAlias(for: hashable)
//            print("Recording \(newAlias) #\(anyHashable.hashValue) for \(String(describing: hashable))")
            hashesToAliases[anyHashable] = newAlias
            return .anchor(newAlias)
        }
    }
    
    public func releaseAnchorReferences() throws {
        hashesToAliases.removeAll()
    }
}

public class StrictCodingStrategy: RedundancyAliasingStrategy {
    private var codedToAliases: [String: Anchor] = [:]
    
    let uniqueAliasProvider = UniqueAliasProvider()
    
    public init() {}
    
    private let encoder = YAMLEncoder()
    
    public func alias(for encodable: any Encodable) throws -> RedundancyAliasingOutcome {
        let coded = try encoder.encode(encodable)
        if let existing = codedToAliases[coded] {
//            print("Recovering \(existing) #\(coded.hashValue) for \(coded)")
            return .alias(existing)
        } else {
            let newAlias = uniqueAliasProvider.uniqueAlias(for: encodable)
//            print("Recording \(newAlias) #\(coded.hashValue) for \(coded))")
            codedToAliases[coded] = newAlias
            return .anchor(newAlias)
        }
    }
    
    public func releaseAnchorReferences() throws {
        codedToAliases.removeAll()
    }
}

class UniqueAliasProvider {
    private var counter = 0
    
    func uniqueAlias(for encodable: any Encodable) -> Anchor {
        if let anchorProviding = encodable as? YamlAnchorProviding,
           let anchor = anchorProviding.yamlAnchor {
            return anchor
        } else {
            counter += 1
            return Anchor(rawValue: String(counter)) 
        }
    }
}

extension CodingUserInfoKey {
    internal static let redundancyAliasingStrategyKey = Self(rawValue: "redundancyAliasingStrategy")!
}
