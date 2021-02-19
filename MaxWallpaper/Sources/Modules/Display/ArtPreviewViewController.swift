//
//  ArtPreviewViewController.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/10/10.
//  Copyright © 2018 大鲨鱼. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Sharaku
import Kingfisher
import AudioToolbox


class ArtPreviewViewController: UIViewController {

    var dismissClosure: DismissFrameClosure?
    var imageInfo: ImageInfo?
    private var hasShowPanelAnimation: Bool = false
    private var hiddenStatusBar: Bool = false
    private weak var guideMask: GuideMaskView?
    private var isUndoFavorite: Bool = false
    fileprivate var enablePanelAnimation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //图片view
    fileprivate lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var panel: OperationPanel = {
        let panel = OperationPanel(frame: CGRect.zero)
        if (imageInfo != nil) {
            let favs: [ImageInfo]? = UserDefaultCache.shared.objects()
            if (favs != nil) {
                if (favs?.contains { $0 == imageInfo })!
                {
                    isUndoFavorite = true
                    panel.favoriteButton.isSelected = true
                } else {
                    isUndoFavorite = false
                    panel.favoriteButton.isSelected = false
                }
            }
        }
        
        //面板的返回按钮
        panel.clickBack = { [weak self](sender) in
            guard let self = self else { return }
            let vc = self.parent?.presentingViewController
            self.dismiss(animated: false, completion: {
                let frame = self.dismissClosure!()
                if frame == CGRect.null {
                    return
                }
                let cover = UIImageView(image: self.imageView.image)
                cover.contentMode = .scaleAspectFill
                cover.isUserInteractionEnabled = true
                cover.frame = vc!.view.bounds
                vc!.view.addSubview(cover)
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                    cover.frame = frame
                }, completion: { (flag) in
                    cover.removeFromSuperview()
                })
            })
        }
        panel.clickDownlaod = { [weak self](sender) in
            self?.download()
        }
        return panel
    }()
    
    //下载到本地相册
    func download() -> Void {
        AuthorizationCheck.checkPhotoLibrary(showAlert: true, goSetting: true) { (isAuthorized) in
            if isAuthorized {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(self.imageSaveFinished(image:error:context:)), nil)
            } else {
                AuthorizationCheck.showAlert(title: "common_alert_title_tip".localized, msg: "photo_library_authorized_tip".localized, goSetting: true)
            }
        }
    }
    
    //图片保存成功
    @objc private func imageSaveFinished(image: UIImage, error: Error?, context: UnsafeRawPointer) {
        let tip = error == nil ? "save_image_to_library_success".localized : "save_image_to_library_failure".localized
        HUDTool.show(msg: tip)
        
        SoundEffect.playSound(name: "success")
        SoundEffect.vibrate(soundID: SystemSoundID(1519))
    }
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    //单击 显示或隐藏功能按钮
    @objc private func tap(_ sender: UITapGestureRecognizer) -> Void {
        if previewView.frame.midX == 0 || previewView.frame.midX == view.bounds.width { // 预览状态下 屏蔽掉点击隐藏
            return
        }
        
        if panel.alpha >= 1 {
            UIView.animate(withDuration: 0.25, animations: {
                self.panel.alpha = 0
            }) { (flag) in }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.panel.alpha = 1
            }) { (flag) in }
        }
    }
    
    //配置 UI 相关的方法
    private func configUI() -> Void {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        view.addSubview(panel)
        panel.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-32 - UIEdgeInsets.systemSafeArea().bottom)
            make.height.equalTo(OperationPanel.minPanelHeight)
        }
        panel.isHidden = true
        view.addSubview(previewView)
    }
    
    //预览视图
    fileprivate lazy var previewView: UIView! = {
        let isX = isiPhoneX()
        let view = UIView(frame: CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width * 2, height: self.view.bounds.height))
        let homeView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        homeView.contentMode = .scaleAspectFill
        homeView.image = UIImage(named: (isX ? "preview_home_iPhoneX" : "preview_home_750"))
        view.addSubview(homeView)
        
        let lockScreenView = UIImageView(frame: CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        lockScreenView.contentMode = .scaleAspectFill
        lockScreenView.image = UIImage(named: (isX ? "preview_lockscreen_iPhoneX" : "preview_lockscreen_750"))
        view.addSubview(lockScreenView)
        return view
    }()
    
    //设置图片
    func setImage(_ image: UIImage?) -> Void {
        imageView.image = image
    }
    
    func setImageWithURL(_ url: String, thumbnail: String? = nil) -> Void {
        guard let url = URL(string: url), let thumbnail = thumbnail else {
            return
        }
        
        ImageTool.cachedImage(thumbnail) { [weak self](image, error) in
            guard let self = self else { return }
            self.imageView.kf.indicatorType = .activity
            let placeholder: UIImage? = image
            self.imageView.kf.setImage(with: ImageResource(downloadURL: url), placeholder: placeholder, options: [.transition(ImageTransition.fade(0.25)), .keepCurrentImageWhileLoading], progressBlock: nil) { (result) in
            }
        }
    }
}

//上下滑动的扩展，可以切换不同的图片
extension ArtPreviewViewController: SwipeScreenItemDelegate {
    static func itemRoomViewController(config: Any?) -> (SwipeScreenItemDelegate)? {
        let vc: ArtPreviewViewController = self.init()
        if let config = config as? SwipeScreenContext {
            vc.enablePanelAnimation = config.isFirstScreen
        }
        return vc
    }
    
    func horizontalPanResponderView() -> UIView? {
        return previewView
    }
    
    func resetWhenInvalidPan() {
        panel.alpha = 1
    }
}
