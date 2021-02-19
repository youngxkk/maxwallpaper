//
//  FoundationConst.swift
//  MaxWallpaper
//
//  Created by elijah on 2019/3/20.
//  Copyright © 2019 elijah. All rights reserved.
//

import Foundation


func JKLog(_ items: Any..., separator: String = " ", terminator: String = "\n",
           _ file: String = #file, _ line: Int = #line, _ function: String = #function) -> Void {
    #if DEBUG
    var str: String = ((file as NSString).pathComponents.last)!
    str = "\(str):\(line):\(function): "
    print(str, items)
    #endif
}


func dispathAsynOnMain(_ closure: @escaping @convention(block) () -> Void) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

func dispathSynOnMain(_ closure: @escaping @convention(block) () -> Void) {
    if !Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

func dispathAsynOnBackground(_ closure: @escaping @convention(block) () -> Void) {
    if Thread.current.isMainThread {
        DispatchQueue.global().async {
            closure()
        }
    } else {
        closure()
    }
}
