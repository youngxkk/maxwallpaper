//
//  LauchSplashViewController.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/25.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

class LauchSplashViewController: UIViewController {
    var splashDuration: TimeInterval = 0.5
    
    override func viewDidLoad() {
        Thread.sleep(forTimeInterval: splashDuration)
    }
}
