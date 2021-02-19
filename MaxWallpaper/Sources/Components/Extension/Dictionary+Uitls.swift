//
//  Dictionary+Uitls.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/8/9.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

extension Dictionary where Value == Any {
    func value<T>(forKey key: Key, defaultValue: @autoclosure () -> T) -> T {
        guard let value = self[key] as? T else {
            return defaultValue()
        }
        return value
    }
}
