//
//  YamlAnchorProviding.swift
//  Yams
//
//  Created by Adora Lynch on 8/15/24.
//  Copyright (c) 2024 Yams. All rights reserved.
//

import Foundation

public protocol YamlAnchorProviding {
    var yamlAnchor: Anchor? { get }
}

public protocol YamlAnchorCoding: YamlAnchorProviding {
    var yamlAnchor: Anchor? { get set }
}

internal extension Node {
    static let anchorKeyNode: Self = .scalar(.init(YamlAnchorFunctionNameProvider().getName()))
}

private final class YamlAnchorFunctionNameProvider: YamlAnchorProviding {
    
    fileprivate var functionName: StaticString?
    
    var yamlAnchor: Anchor? {
        functionName = #function
        return nil
    }
    
    func getName() -> StaticString {
        _ = yamlAnchor
        return functionName!
    }
    
    func getName() -> String {
        String(describing: getName() as StaticString)
    }
}
