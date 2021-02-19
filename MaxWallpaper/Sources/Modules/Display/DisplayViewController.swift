//
//  DisplayViewController.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/6.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


typealias ImageListUpdateClosure = () -> Void
typealias DismissToItemFrameClosure = (_ idx: Int) -> CGRect

class DisplayViewController: UIViewController {
    
    // MARK:
    var swipeScreenContext: SwipeScreenContext! = SwipeScreenContext()
    var imageInfos: Array<ImageInfo>? 
    var currentIdx: Int = 0
    var updateImageInfos: ImageListUpdateClosure?
    var dismissClosure: DismissToItemFrameClosure?
    
    fileprivate lazy var proxy: SwipeScreenProxy! = {
        let proxy = SwipeScreenProxy(container: self)
        proxy.animationDuration = 0.3
        return proxy
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        relodItem()
    }
    
    // MARK: status bar
    override var prefersStatusBarHidden: Bool {
        get { return true }
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return proxy.currentItem as? UIViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return proxy.currentItem as? UIViewController
    }
    
    // MARK: Private
    private func configUI() -> Void {
        let bgView = UIImageView(frame: view.bounds)
        bgView.contentMode = .scaleAspectFill
        bgView.image = UIImage(named: "default_placehold_l")
        view.addSubview(bgView)
        
        view.clipsToBounds = true
    }
    
    private func relodItem() -> Void {
        proxy.reloadItems()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func prepareBackground(imageInfo: ImageInfo?, view: UIView?) {
        guard let imageInfo = imageInfo, let urlString = imageInfo.thumbnail, let imageView = view?.subviews.first as? UIImageView, let url = URL(string: urlString) else {
            return
        }
        let placeholder: UIImage? = UIImage(named: "default_placehold_l")
        imageView.kf.setImage(with: ImageResource(downloadURL: url), placeholder: placeholder, options: [.downloadPriority(1.0), .transition(ImageTransition.none), .keepCurrentImageWhileLoading], progressBlock: nil) { (result) in
            
        }
    }
}

extension DisplayViewController: SwipeScreenDelegate, SwipeScreenDataSource, SwipeScreenDataPrefetching {
    var globalContext: Any? {
        get {
            return swipeScreenContext
        }
        set {
            swipeScreenContext = newValue as? SwipeScreenContext
        }
    }
    
    func itemViewController(_ swipeVC: UIViewController?) -> (SwipeScreenItemDelegate)? {
        if currentIdx >= imageInfos?.count ?? 0 {
            // 临时处理
            if let vc = presentingViewController {
                vc.dismiss(animated: true) {
                    if vc is UINavigationController {
                        (vc as! UINavigationController).popViewController(animated: true)
                    }
                }
            }
            return nil
        }
        let vc = PreviewViewController.itemRoomViewController(config: globalContext) as! PreviewViewController
        vc.imageInfo = imageInfos?[currentIdx]
        vc.dismissClosure = { [weak self] in
            if let sSelf = self {
                if let closure = sSelf.dismissClosure {
                    return closure(sSelf.currentIdx)
                }
                return CGRect.null
            }
            return CGRect.null
        }
        
        // 提前拉取数据
        if currentIdx >= (imageInfos?.count)! - 4 {
            if let closure = updateImageInfos {
                closure()
            }
        }
        if let globalCxt = globalContext as? SwipeScreenContext {
            if globalCxt.isFirstScreen {
                vc.setImage(globalCxt.firstScreenThumnailImage)
                globalCxt.firstScreenThumnailImage = nil
                globalCxt.isFirstScreen = false
            }
        }
        return vc
    }
    
    func itemCount() -> Int {
        return 3;
    }
    
    func prepareForSwipe(in swipVC: UIViewController?, previousView: UIView?, nextView: UIView?) {
        func buidleNewImageView() -> UIImageView! {
            let imageView = UIImageView(frame: view.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.clipsToBounds = true
            return imageView
        }
        if previousView?.subviews.count == 0 {
            previousView?.addSubview(buidleNewImageView())
        }
        if nextView?.subviews.count == 0 {
            nextView?.addSubview(buidleNewImageView())
        }
    }
    
    func background(previousView: UIView?, nextView: UIView?) {
        let count = imageInfos!.count
        if count <= 0 {
            return
        }
        var idx = currentIdx - 1
        if 0 >= idx {
            idx = count - 1
        }
        prepareBackground(imageInfo: imageInfos![idx], view: previousView)
        idx = currentIdx + 1
        if count <= idx {
            idx = 0
        }
        prepareBackground(imageInfo: imageInfos![idx], view: nextView)
    }
    
    func swipeViewController(_ swipeVC: UIViewController?, end gesture: UIGestureRecognizer?, direction: PanDirection) -> Void {
        if direction == .left || direction == .right {
            setNeedsStatusBarAppearanceUpdate()
            return
        }
        var idx: Int = currentIdx
        let count = imageInfos == nil ? 0 : imageInfos!.count
        switch direction {
        case .up:
            idx = idx + 1
            if idx >= count {
                idx = 0
            }
        case .down:
            idx = idx - 1
            if idx < 0 {
                idx = count - 1
            }
        default:
            log.info("swipe exception")
            break
        }
        currentIdx = idx
        relodItem()
    }
}
