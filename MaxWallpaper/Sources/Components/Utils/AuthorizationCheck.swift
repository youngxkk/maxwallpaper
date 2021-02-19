//
//  AuthorizationCheck.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/7/9.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//
import AVFoundation
import UIKit
import Photos
import MobileCoreServices
import EventKit
    
public class AuthorizationCheck {
    // MARK: 弹窗工具
    class func showAlert(title: String?, msg: String?, goSetting: Bool) {
        let titleName: String! = title != nil ? title : ""
        let msgContent: String! = msg != nil ? msg : ""
        DispatchQueue.main.async {
            var originWindow: UIWindow? = nil
            let app = UIApplication.shared
//                NSClassFromString("UIApplication")?["sharedApplication"]
            let windows = app.windows
//                app?.perform(#selector(self.windows)) as? [Any]
            for window: UIWindow? in windows {
                if window?.windowLevel == UIWindow.Level.normal {
                    originWindow = window
                    break
                    // 返回最底层 第一个normal window
                }
            }
            if originWindow == nil {
                return
            }
            
            let alertVC = UIAlertController(title: titleName, message: msgContent, preferredStyle: .alert)
            var cancelTitle = ""
            let alerWindow = UIWindow(frame: UIScreen.main.bounds)
            alerWindow.windowLevel = UIWindow.Level.alert
            let vc = UIViewController()
            alerWindow.rootViewController = vc
            alerWindow.makeKeyAndVisible()
            if goSetting {
                cancelTitle = "取消"
                let actionSetting = UIAlertAction(title: "去设置", style: .default, handler: { action in
                        let rootURL = UIApplication.openSettingsURLString
                        let url = URL(string: rootURL)!
                        let flag = app.canOpenURL(url)
                        if flag {
                            app.open(url, options: [:], completionHandler: { (success) in
                                
                            })
                        }
                        alerWindow.isHidden = true
                        alerWindow.removeFromSuperview()
                        originWindow?.makeKeyAndVisible()
                    })
                alertVC.addAction(actionSetting)
                alertVC.preferredAction = actionSetting
            } else {
                cancelTitle = "知道了"
            }
        
            let actionCancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: { action in
                    alerWindow.isHidden = true
                    alerWindow.removeFromSuperview()
                    originWindow?.makeKeyAndVisible()
            })
            alertVC.addAction(actionCancel)
            vc.present(alertVC, animated: true, completion: {})
        }
    }
    
    // MARK: 音频
    class func checkAudio(showAlert: Bool, goSetting: Bool, callback: @escaping (_ isAuthorized: Bool) -> Void) {
        let permission: AVAudioSession.RecordPermission = AVAudioSession.sharedInstance().recordPermission
        if .undetermined == permission {
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                DispatchQueue.main.async {
                    callback(granted)
                }
            })
        } else {
            var isAuthorized = false
            if .granted == permission {
                isAuthorized = true
            } else if .denied == permission {
                isAuthorized = false
            }
            DispatchQueue.main.async {
                callback(isAuthorized)
            }
        }
    }
    
    // MARK: 相机
    class func checkCamera(showAlert: Bool, goSetting: Bool, callback: @escaping (_ isAuthorized: Bool) -> Void) {
        let permission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if .notDetermined == permission {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    callback(granted)
                }
            }
        } else {
            var isAuthorized = false
            if .restricted == permission || .notDetermined == permission {
                isAuthorized = false
            } else if .authorized == permission {
                isAuthorized = true
            }
            DispatchQueue.main.async {
                callback(isAuthorized)
            }
        }
    }
    
    // MARK: 相册
    class func checkPhotoLibrary(showAlert: Bool, goSetting: Bool, callback: @escaping (_ isAuthorized: Bool) -> Void) {
        let permission: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if .notDetermined == permission {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    callback(status == .authorized)
                }
            }
        } else {
            var isAuthorized = false
            if .restricted == permission || .notDetermined == permission {
                isAuthorized = false
            } else if .authorized == permission {
                isAuthorized = true
            }
            DispatchQueue.main.async {
                callback(isAuthorized)
            }
        }
    }
    
}
