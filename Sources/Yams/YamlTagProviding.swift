//
//  YamlTagProviding.swift
//
//
//  Created by Adora Lynch on 9/5/24.
//  Copyright (c) 2016 Yams. All rights reserved.
//


public protocol YamlTagProviding {
    var yamlTag: Tag? { get }
}

public protocol YamlTagCoding: YamlTagProviding {
    var yamlTag: Tag? { get set }
}

internal extension Node {
    static let tagKeyNode: Self = .scalar(.init(YamlTagFunctionNameProvider().getName()))
}

private final class YamlTagFunctionNameProvider: YamlTagProviding {
    
    fileprivate var functionName: StaticString?
    
    var yamlTag: Tag? {
        functionName = #function
        return nil
    }
    
    func getName() -> StaticString {
        _ = yamlTag
        return functionName!
    }
    
    func getName() -> String {
        String(describing: getName() as StaticString)
    }
}
