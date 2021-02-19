//
//  SoundAndVibrate.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/7/27.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundEffect {
    
    //下面是声音相关
    class func playSound(name: String, type: String? = nil) -> Void {
        let isOpen: Bool = UserSettingConfig.soundEffectStatus()
        if !isOpen {
            return
        }
        
        var soundID = SystemSoundID(0)
        //获取声音地址
        let path = Bundle.main.path(forResource: name, ofType: type ?? "mp3")
        if path == nil {
            return
        }
        let baseURL = NSURL(fileURLWithPath: path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        //播放声音
        AudioServicesPlaySystemSound(soundID)
    }

    class func vibrate(soundID: SystemSoundID) -> Void {
        let isOpen: Bool = UserSettingConfig.soundEffectStatus()
        if !isOpen {
            return
        }
        
        // 建立的SystemSoundID对象,标准长震动
        //        let soundID = SystemSoundID(kSystemSoundID_Vibrate)
        //        //短振动，普通短震，3D Touch 中 Peek 震动反馈
        //        let soundShort = SystemSoundID(1519)
        //        //普通短震，3D Touch 中 Pop 震动反馈
        //        let soundMiddle = SystemSoundID(1520)
        //        // 连续三次短震
        //        let soundThere = SystemSoundID(1521)
        //执行震动
        AudioServicesPlaySystemSound(soundID)
    }
}
