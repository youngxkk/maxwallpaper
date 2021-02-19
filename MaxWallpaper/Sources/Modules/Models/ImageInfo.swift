//
//  ImageInfo.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/6.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation

class ImageInfo: NSObject, NSCoding { // Codable
    
    var imgID: String? = nil
    var imgURL: String? = nil
    var thumbnail: String? = nil
    var name: String? = nil
    var size: Int = 0
    var createTime: Int64 = 0
    
//    func encode(to encoder: Encoder) throws {
//
//    }
//
//    func init(from decoder: Decoder) throws {
//
//    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imgID, forKey: "imgID")
        aCoder.encode(imgURL, forKey: "imgURL")
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(size, forKey: "size")
        aCoder.encode(createTime, forKey: "createTime")
    }
    
    required init?(coder aDecoder: NSCoder) {
        imgID = aDecoder.decodeObject(forKey: "imgID") as? String
        imgURL = aDecoder.decodeObject(forKey: "imgURL") as? String
        thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        size = aDecoder.decodeInteger(forKey: "size")
        createTime = aDecoder.decodeInt64(forKey: "createTime")
        
        super.init()
    }
    
    required override init() {
        super.init()
    }
    
    fileprivate class func parseImageInfo(data: Array<Dictionary<String, Any>>?) -> Array<ImageInfo>? {
        var infos: Array<ImageInfo>?
        if let d = data {
            infos = [ImageInfo]()
            for meta: Dictionary<String, Any> in d {
                let info = ImageInfo()
                info.imgURL = meta["rawUrl"] as? String
                info.thumbnail = meta["url"] as? String
                info.name = meta["name"] as? String
                info.size = meta["size"] as! Int
                info.createTime = meta["createTime"] as! Int64
                
                infos!.append(info)
            }
        }
        return infos
    }
    
    class func fetchImageList(page: Int, pageSize: Int, isEasterEgg: Bool = false, compeletion: ((_ error: Error?, _ code: BussinessStatusCode, _ newData: Array<ImageInfo>?, _ hasMore: Bool, _ totalCount: Int) -> Void)?) -> Void {
        var parms: Dictionary<String, Any> = ["page": page, "pageSize": pageSize]
        #if DEBUG
        parms["token"] = "1198dfaa-cd7c-4427-b911-d8e7924dc431"
        #endif
        let url = isEasterEgg ? "/beauty/images/list" : "/images/list"
        
        NetworkManager.shared.GET(url, parameters: parms) { (error, rsp) in
            if error == nil {
                if let rsp = rsp {
                    let data: Dictionary<String, Any>? = rsp["data"] as? Dictionary<String, Any>
                    var totalCount: Int = 0
                    var newData: Array<ImageInfo>? = nil
                    if let data = data {
                        let infos: Array<Dictionary<String, Any>>? = data["images"] as? Array<Dictionary<String, Any>>
                        if let infos = infos {
                            totalCount = data["totalCount"] as! Int
                            newData = ImageInfo.parseImageInfo(data:infos)
                        }
                    }
                    let code = rsp["code"] as! Int
                    if let closure = compeletion {
                        closure(nil, BussinessStatusCode.code(raw: code), newData, (newData?.count ?? 0) >= pageSize, totalCount)
                    }
                }
            } else {
                if let closure = compeletion {
                    closure(error, .failure, nil, true, -1)
                }
            }
        }
    }
    
    
    // MARK:
    public var dictionaryData: Dictionary<String, Any> {
        get {
            var info: Dictionary<String, Any> = Dictionary<String, Any>()
            info["imgID"] = (self.imgID ?? "")
            info["imgURL"] = (self.imgURL ?? "")
            info["thumbnail"] = (self.thumbnail ?? "")
            info["name"] = (self.name ?? "")
            info["size"] = (self.size)
            info["createTime"] = (self.createTime)
            
            return info
        }
        set {
            self.imgID = self.dictionaryData["imageID"] as? String;
            self.imgURL = self.dictionaryData["imgURL"] as? String;
            self.thumbnail = self.dictionaryData["thumbnail"] as? String;
            self.name = self.dictionaryData["name"] as? String;
            self.size = self.dictionaryData["size"] as! Int;
            self.createTime = self.dictionaryData["createTime"] as! Int64;
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let imageInfo = object as? ImageInfo else { return false }
        return self == imageInfo
    }
    
    static public func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
        return lhs.createTime == rhs.createTime && lhs.imgURL == rhs.imgURL
    }
    
    public override var debugDescription: String {
        get {
            return """
            "imgID": \(imgID ?? ""),
            "imgURL": \(imgURL ?? ""),
            "thumbnail": \(thumbnail ?? ""),
            "name": \(name ?? ""),
            "size": \(size),
            "createTime": \(createTime)
            """
        }
    }
}

//extension ImageInfo: CustomDebugStringConvertible {
//    var debugDescription: String {
//        return """
//        "imgID": \(imgID ?? ""),
//        "imgURL": \(imgURL ?? ""),
//        "thumbnail": \(thumbnail ?? ""),
//        "name": \(name ?? ""),
//        "size": \(size),
//        "createTime": \(createTime)
//        """
//    }
//}
