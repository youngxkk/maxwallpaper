//
//  PhotoAlbumTool.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/7/9.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//
import AVFoundation
import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    // ==========  保存照片到系统相册  done   ==========
    func savePhotoAlbum() {
        let image = self.imageView.image!
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("照片保存成功!")
            } else{
                print("照片保存失败!", error!.localizedDescription)
            }
        }
    }
    
    
    
    //=========  打开相册的方法  done  ==========
    func openPhotoAlbum(){
        let pickImageController:UIImagePickerController=UIImagePickerController.init()
        if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            //获取相册权限
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .notDetermined: break
                case .restricted://此应用程序没有被授权访问的照片数据
                    break
                case .denied://用户已经明确否认了这一照片数据的应用程序访问
                    break
                case .authorized://已经有权限
                    //跳转到相机或者相册
                    pickImageController.delegate=self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                    pickImageController.allowsEditing = true
                    pickImageController.sourceType = UIImagePickerController.SourceType.photoLibrary;
                    //弹出相册页面或相机
                    self.present(pickImageController, animated: true, completion: {})
                    break
                @unknown default:
                    break
                }
            })
        }
    }
    
    

    // ==========  保存视频到系统相册 - 没测试   ==========
    func saveVideoAlbum(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
        print("视频保存成功")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
