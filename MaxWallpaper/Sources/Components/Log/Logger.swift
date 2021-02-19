//
//  Logger.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/4.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import CocoaLumberjack

let log = Logger.self
fileprivate let DD_LOG_LEVEL: DDLogLevel = DDLogLevel.info

class Logger {
    class func launchConfig() -> Void {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 8
        DDLog.add(fileLogger)
    }
    
    class func error(_ message: @autoclosure () -> String) -> Void {
        DDLogError(message(), level: DD_LOG_LEVEL)
    }
    class func warn(_ message: @autoclosure () -> String) -> Void {
        DDLogWarn(message(), level: DD_LOG_LEVEL)
    }
    class func info(_ message: @autoclosure () -> String) -> Void {
        DDLogInfo(message(), level: DD_LOG_LEVEL)
    }
    class func debug(_ message: @autoclosure () -> String) -> Void {
        DDLogDebug(message(), level: DD_LOG_LEVEL)
    }
    class func verbose(_ message: @autoclosure () -> String) -> Void {
        DDLogVerbose(message(), level: DD_LOG_LEVEL)
    }
}
