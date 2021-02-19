//
//  UIViewController+Utils.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/8/5.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class var current: UIViewController {
        get {
            let rootVC: UIViewController! = UIApplication.shared.delegate!.window!?.rootViewController!
            return findBest(rootVC)
        }
    }
    
    private class func findBest(_ vc: UIViewController) -> UIViewController {
        if (vc.presentedViewController != nil) {
            // Return presented view controller
            return findBest(vc.presentedViewController!)
            
        } else if (vc is UISplitViewController) {
            // Return right hand side
            let svc = vc as! UISplitViewController;
            if (svc.viewControllers.count > 0) {
                return findBest(svc.viewControllers.last!)
            } else {
                return vc
            }
        } else if (vc is UINavigationController) {
            // Return top view
            let svc = vc as! UINavigationController
            if (svc.viewControllers.count > 0) {
                return findBest(svc.topViewController!)
            } else {
                return vc
            }
        } else if (vc is UITabBarController) {
            // Return visible view
            let svc = vc as! UITabBarController
            if ((svc.viewControllers?.count)! > 0) {
                return findBest(svc.selectedViewController!)
            } else {
                return vc;
            }
        } else {
            // Unknown view controller type, return last child view controller
            return vc;
        }
    }
}
