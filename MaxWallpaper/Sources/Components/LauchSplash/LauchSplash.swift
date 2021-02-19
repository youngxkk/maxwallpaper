//
//  LauchSplash.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/25.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

class LauchSplash {
    static var splashDuration: TimeInterval = 0.5
    
    static private var originalRootViewController: UIViewController?
    
    class func start(window: UIWindow!) -> Void {
        originalRootViewController = window.rootViewController
        let vc = LauchSplashViewController()
        vc.splashDuration = splashDuration
        window.rootViewController = vc
        
        DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
            let window = UIApplication.shared.delegate?.window
            window??.rootViewController = originalRootViewController
        }
    }
}
