//
//  SandboxTool.swift
//  MaxWallpaper
//
//  Created by youngxkk on 2018/7/8.
//  Copyright © 2018 youngxkk. All rights reserved.
//

import Foundation
import UIKit

//第一层文件夹名称
let CACHEPATH = "doudashen"

//内层文件夹名称
let MarkingPath = "doudashenniubility"


class SandboxTool {
    
    //获取Home目录路径的函数
    func getHomePath()->String{
        let homePath = NSHomeDirectory()
        return homePath
    }
    
    //获取Caches目录路径的方法
    func getCachePath()->String{
        let paths =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = paths[0]
        return cachePath
    }
    
    //获取Documents目录路径的方法
    func getDocumentsPath()->String{
        let paths =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsPath = paths[0]
        return documentsPath
    }
    
    //获取tmp目录路径的方法：
    func getTmpPath()->String{
        let tmpPath = NSTemporaryDirectory()
        return tmpPath
    }
    
    //获取应用程序程序包（NSBundle）中资源文件路径的方法
    func getBoundlePath(name: String?, type: String?)->String? {
        let boundlePath = Bundle.main.path(forResource: name, ofType: type)
        return boundlePath!
    }
    
    
    //判断文件夹是否存在
    func dirExists(dir:String)->Bool{
        return FileManager.default.fileExists(atPath: dir)
    }
    
    //判断文件是否存在
    func fileExists(path:String)->Bool{
        return dirExists(dir: path)
    }
    
    //判断是否存在,存在则返回文件路径，不存在则返回nil
    func fileExistsWithFileName(fileName:String)->String?{
        let dir = getCachePath()
        if(!dirExists(dir: dir)){
            return nil
        }
        let filePath = dir + fileName
        
        return fileExists(path: filePath) ? filePath : nil
    }
    
    
    //创建文件夹
    func createDir(dir:String)->Bool{
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: NSURL(fileURLWithPath: dir, isDirectory: true) as URL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        return true
    }
    
    // 根据文件名创建路径
    //
    // - Parameter fileName: 文件名
    // - Returns: <#return value description#>
    func createFilePath(fileName:String)->String?{
        let dir = getCachePath()
        if(!dirExists(dir: dir) && !createDir(dir: dir)){
            return nil
        }
        let filePath = dir + fileName
        if(fileExists(path: filePath)){
            do{
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                return nil
            }
            
        }
        return filePath
    }
    
    //删除文件 - 根据文件名称
    //
    // - Parameter fileName: fileName description
    // - Returns: <#return value description#>
    func deleteFileWithName(fileName:String)->Bool{
        guard let filePath = fileExistsWithFileName(fileName: fileName) else{
            return true
        }
        return deleteFile(path: filePath)
    }
    
    //删除文件夹 - 根据文件路径
    //
    // - Parameter path: <#path description#>
    // - Returns: <#return value description#>
    func deleteFile(path:String)->Bool{
        if(!fileExists(path: path)){
            return true
        }
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: path)
        }catch{
            return false
        }
        
        return true
    }
    
    /**
     清除所有的缓存
     - returns: Bool
     */
    func deleteAll()->Bool{
        let dir = getCachePath()
        if !dirExists(dir: dir){
            return true
        }
        let manager = FileManager.default
        do{
            try manager.removeItem(atPath: dir)
        }catch{
            return false
        }
        return true
    }
    
    
}


//    let fileManager = FileManager.default
//    let myDirectory = NSHomeDirectory() + "/Documents/Files"
//    let fileArray = fileManager.subpaths(atPath: myDirectory)
//    try! fileManager.removeItem(atPath: myDirectory)
//    try! fileManager.createDirectory(atPath: myDirectory, withIntermediateDirectories: true,attributes: nil)




