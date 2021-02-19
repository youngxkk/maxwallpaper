//
//  APPStoreReview.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/13.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class APPStoreReview: NSObject {
    class func showReview() -> Void {
        if #available(iOS 10.3, *) {
            UIApplication.shared.keyWindow?.endEditing(true)
            SKStoreReviewController.requestReview()
        } else {
            let appid = "156093462" // TODO:
            let url = "itms-apps://itunes.apple.com/app/id\(appid)?action=write-review"
            UIApplication.shared.open(URL(string: url)!, options: [:]) { (success) in
                
            }
        }
    }
}
