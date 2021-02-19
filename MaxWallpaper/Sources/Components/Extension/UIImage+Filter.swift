//
//  UIImage+Filter.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/4.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var height : CGFloat{return self.size.height}
    var width  : CGFloat{return self.size.width}
    
    // 压缩图片
    func imageCompress(targetWidth:CGFloat) -> UIImage {
        let targetHeight = (targetWidth/width)*height
        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: targetHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //模糊图片
    func blurImage(blurValue:NSNumber) -> UIImage {
        let context = CIContext(options: convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.useSoftwareRenderer): true]))
        let ciImage = CoreImage.CIImage(image: self)
        let blurFilter = CIFilter(name: "CJGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurValue, forKey: "inputRadius")
        let imageRef = context.createCGImage((blurFilter?.outputImage)!, from: (ciImage?.extent)!)
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
}
//高斯模糊的方法
public func insertBlurView (view: UIView, style: UIBlurEffect.Style) -> UIVisualEffectView {
    view.backgroundColor = UIColor.clear
    
//    let blurEffect = UIBlurEffect(style: .light)
//    let blurView = UIVisualEffectView(effect: blurEffect)
//    blurView.frame = CGRect(x: (self.view.bounds.width - 260) / 2, y: ( self.view.bounds.height / 4 ) + 20, width: 260, height: 260)
//    self.view.addSubview(blurView)
    
    let blurEffect = UIBlurEffect(style: .dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    view.insertSubview(blurEffectView, at: 0)
    return blurEffectView
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
	return input.rawValue
}
