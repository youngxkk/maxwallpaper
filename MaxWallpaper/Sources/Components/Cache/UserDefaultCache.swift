//
//  UserDefaultCache.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/8/6.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

class UserDefaultCache: Persistable {    
    
    private let suiteName: String
    private let defalutKey: String
    
    static let shared = UserDefaultCache()
    init() {
        suiteName = "MaxWallpaper.UserDefault.cache"
        defalutKey = "cachedImageInfo"
    }
    
    typealias T = NSCoding
    
    func add<T>(object: T) {
        let userDefault = UserDefaults(suiteName: suiteName)
        if let ud = userDefault {
            let decodedData = ud.object(forKey: defalutKey) as? Data
            var data = [T]()
            if decodedData != nil {
                data = (NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? [T])!
            }
            data.append(object)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
            ud.set(encodedData, forKey: defalutKey)
        }
    }
    
    func objects<T>() -> [T]? {
        let userDefault = UserDefaults(suiteName: suiteName)
        let decodedData  = userDefault?.object(forKey: defalutKey) as? Data
        if decodedData != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? [T]
        }
        return nil;
    }
    
    func remove<T: Equatable>(object: T) -> Void {
        let userDefault = UserDefaults(suiteName: suiteName)
        if let ud = userDefault {
            let decodedData  = userDefault?.object(forKey: defalutKey) as? Data
            if decodedData != nil {
                let data = NSKeyedUnarchiver.unarchiveObject(with: decodedData!) as? [T]
                if data != nil {
                    let newData = data?.filter { $0 != object }
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newData as Any)
                    ud.set(encodedData, forKey: defalutKey)
                }
            }
        }
    }
    
    func clear() -> Void {
        let userDefault = UserDefaults(suiteName: suiteName)
        userDefault?.removeObject(forKey: defalutKey)
    }
}

class UserSettingConfig {
    private static let SoundEnableKey: String = "SoundEnableKey"
    class func setSoundEffect(_ enable: Bool) -> Void {
        UserDefaults.standard.set(enable, forKey: SoundEnableKey)
    }
    
    class func soundEffectStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: SoundEnableKey)
    }
}

