//
//  Namespace.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/3.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

public protocol NamespaceWrappable {
    associatedtype HandWrapperType
    var hand: HandWrapperType { get }
    static var hand: HandWrapperType.Type { get }
}

public extension NamespaceWrappable {
    var hand: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }
    
    static var hand: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}

public struct NamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
