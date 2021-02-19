//
//  HUDTool.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/10.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import Chrysan
import RSLoadingView

class HUDTool {
    class func defaultProgressImages() -> Array<UIImage> {
        return progressImages(bundle: "Loading")
    }
    
    class func progressImages(bundle: String) -> Array<UIImage> {
        let path = Bundle.main.path(forResource: bundle, ofType: "bundle")
        assert(path != nil)
        let loadingBundle = Bundle(path: path!)
        let paths = try? FileManager.default.contentsOfDirectory(atPath: path!)
        assert(paths != nil)
        var images: Array<UIImage> = []
        for p in paths! {
            images.append(UIImage(named: p, in: loadingBundle, compatibleWith: nil)!)
        }
        return images
    }
    
    private var loadingView: RSLoadingView!
    private var targetView: UIView?
    
    private static let shared = HUDTool()
    //This prevents others from using the default '()' initializer for this class.
    init() {
        loadingView = RSLoadingView(effectType: RSLoadingView.Effect.spinAlone)
        loadingView.speedFactor = 3
        loadingView.sizeInContainer = CGSize(width: 120, height: 120)
    }
    
    class func showLoading(on view: UIView? = nil) -> Void {
        shared.targetView = view ?? UIApplication.shared.delegate?.window!
        shared.loadingView.show(on: shared.targetView!)
    }
    
    class func hideLoading() -> Void {
        RSLoadingView.hide(from: shared.targetView!)
    }
    
    class func showActivity() -> Void {
        UIViewController.current.chrysan.show()
    }
    
    class func hideActivity() -> Void {
        UIViewController.current.chrysan.hide()
    }
    
    class func show(msg: String, icon: String? = nil, view: UIView? = nil, durationBase: TimeInterval = 0.25, completion: ((Bool) -> Void)? = nil) -> Void {
        let duration: TimeInterval = durationBase + Double(msg.count) * 0.02
        UIViewController.current.chrysan.show(.plain, message: msg, hideDelay: duration)
    }
}
