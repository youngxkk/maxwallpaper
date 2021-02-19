//
//  Persistable.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/8/10.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation


/// 数据持久化 增删改查的接口定义
protocol Persistable {
    associatedtype T: Any
    
    func add<T>(object: T) -> Void
    
    func objects<T>() -> [T]?
    
    func remove<T: Equatable>(object: T) -> Void
    
    func clear() -> Void
    
    // MARK: optional
    func setObject<T>(object: T, for key: String) -> Void
    
    func append<T>(objects: [T]) -> Void
}

extension Persistable {
    func setObject<T>(object: T, for key: String) -> Void {}
    func append<T>(objects: [T]) -> Void {}
}
