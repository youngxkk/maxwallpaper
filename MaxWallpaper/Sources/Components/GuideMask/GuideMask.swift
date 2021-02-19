//
//  GuideMask.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/26.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

class GuideMaskView: UIView {
    private var images: Array<String>?
    private var idx: Int = 0
    private var imgView: UIImageView?
    
    @discardableResult class func mask(for cls: AnyClass, appendKey: String? = nil, on view: UIView?, maskImages: [String]) -> GuideMaskView? {
        let key = NSStringFromClass(cls) + (appendKey ?? "") + "Masked"
        let isMasked = UserDefaults.standard.bool(forKey: key)
        if isMasked {
            return nil
        }
        
        let target = view ?? UIApplication.shared.delegate?.window!
        assert(target != nil)
        let mask = GuideMaskView(frame: target!.bounds)
        mask.images = maskImages
        target!.addSubview(mask)
        UserDefaults.standard.set(true, forKey: key)
        
        return mask
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imgView = UIImageView(frame: frame)
        imgView!.contentMode = .scaleAspectFit
        addSubview(imgView!)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_ :)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        showNextImage()
    }
    
    func removeMask() -> Void {
        removeFromSuperview()
    }
    
    private func showNextImage() -> Void {
        if idx < images!.count {
            let img = UIImage(named: images![idx])
//                ?? UIImage(named: Bundle.main.path(forResource: images![idx], ofType: "jpg"))
            imgView!.image = img
        } else {
            removeFromSuperview()
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) -> Void {
        idx += 1
        showNextImage()
    }
}
