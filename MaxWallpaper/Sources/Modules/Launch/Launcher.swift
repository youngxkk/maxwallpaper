//
//  Launcher.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/23.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import KingfisherWebP
import Firebase
import Fabric
import Crashlytics


class Launcher: NSObject, CrashHandlerProtocol {
    class func config(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Void {
        // 配置Crashlytics
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        // 配置图片库支持webp
        KingfisherManager.shared.defaultOptions = [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
        KingfisherManager.shared.cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024
//        let url = URL(string: "url_of_your_webp_image")
//        imageView.kf.setImage(with: url, options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)])
        
        CrashHandler.configCrashHandler(self)
        
        Logger.launchConfig()
    }
    
    static func handleCarsh(_ crash: CarashInfo) {
        Crashlytics.sharedInstance().setObjectValue(UIViewController.current, forKey: "CurrentViewController")
        Crashlytics.sharedInstance().setIntValue(Int32(UIApplication.shared.applicationState.rawValue), forKey: "AppState")
    }
}
