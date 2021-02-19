//
//  BussinessStatusCode.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/10/9.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

enum BussinessStatusCode: Int {
    case failure = -1
    case success = 0 // success, data is correct
    case noData = 1
    case limited = 2
    
    static func code(raw: Int) -> BussinessStatusCode {
        switch raw {
        case 0:
            return .success
        case 1:
            return .noData
        case 2:
            return .limited
        default:
            return .failure
        }
    }
}
