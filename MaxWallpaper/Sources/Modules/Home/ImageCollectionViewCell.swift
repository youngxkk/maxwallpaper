//
//  ImageCollectionViewCell.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/6.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher


class ImageCollectionViewCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imgView: UIImageView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true;
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    private func configUI() -> Void {
        contentView.addSubview(self.imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
    }
    
    public func setImageURL(_ url: String) -> Void {
        guard let url = URL(string: url) else {
            return
        }
        imageView.kf.setImage(with: ImageResource(downloadURL: url), placeholder: UIImage(named: "default_placehold_s"), options: [.transition(ImageTransition.none), .keepCurrentImageWhileLoading], progressBlock: nil) { (result) in
            
        }
    }
    
    public func currentImage() -> Image? {
        return imageView.image
    }
}
