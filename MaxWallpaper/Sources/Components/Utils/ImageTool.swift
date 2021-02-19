//
//  ImageTool.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/13.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import Kingfisher
import KingfisherWebP

class ImageTool {
    class func clearAllCache() -> Void {
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()//清理网络缓存
        cache.clearDiskCache()//清除硬盘缓存
        cache.cleanExpiredDiskCache()//清理过期的，或者超过硬盘限制大小的
    }
    
//    class func memoryCachedImage(_ url: String) -> UIImage? {
//        return KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url, options: nil)
//    }
    
    class func cachedImage(_ url: String, completion: @escaping (UIImage?, Error?) -> Void) -> Void {
        KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: url)!), options: [.onlyFromCache]) { (result) in
            dispathAsynOnMain {
                switch result {
                case .success(let value):
                    completion(value.image, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
}

