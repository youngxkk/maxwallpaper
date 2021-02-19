//
//  UIConst.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/3.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import SDVersion

let onePixel = CGFloat(1.0 / UIScreen.main.scale)
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

func isiPhoneX() -> Bool {
    return SDiOSVersion.deviceSize() == .Screen5Dot8inch
}

func RGBColor(r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: 1.0)
}

func HexColor(hex:integer_t, alpha:CGFloat) -> UIColor
{
    return UIColor(red: CGFloat((hex >> 16) & 0xff)/255.0, green: CGFloat((hex >> 8) & 0xff)/255.0, blue: CGFloat(hex & 0xff)/255.0, alpha: alpha)
}

extension UIEdgeInsets {
    static func safeArea(_ view: UIView!) -> UIEdgeInsets {
        if #available(iOS 11, *) {
            return view.safeAreaInsets;
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    static func systemSafeArea() -> UIEdgeInsets {
        return safeArea(UIApplication.shared.delegate!.window!)
    }
}

