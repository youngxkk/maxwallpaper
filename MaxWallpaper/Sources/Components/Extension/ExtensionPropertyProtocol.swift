//
//  ExtensionPropertyProtocol.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/16.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

protocol ExtensionPropertyProtocol {
    associatedtype T
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, value: T) -> T
    func setAssociatedObject(_ key: UnsafeRawPointer, value: T, policy: objc_AssociationPolicy) -> Void
}

extension ExtensionPropertyProtocol {
    func getAssociatedObject(_ key: UnsafeRawPointer!, value: T) -> T {
        guard let v = objc_getAssociatedObject(self, key) as? T else {
            return value
        }
        return v
    }
    
    func setAssociatedObject(_ key: UnsafeRawPointer, value: T, policy: objc_AssociationPolicy) -> Void {
        objc_setAssociatedObject(self, key, value, policy)
    }
}
