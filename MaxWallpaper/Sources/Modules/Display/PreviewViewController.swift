//
//  PreviewViewController.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/9.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Sharaku
import Kingfisher
import AudioToolbox


typealias DismissFrameClosure = () -> CGRect

class PreviewViewController: UIViewController {
    var dismissClosure: DismissFrameClosure?
    var imageInfo: ImageInfo?
    private var hasShowPanelAnimation: Bool = false
    private var hiddenStatusBar: Bool = false
    private weak var guideMask: GuideMaskView?
    private var isUndoFavorite: Bool = false
    fileprivate var enablePanelAnimation: Bool = true
    
    //图片view
    fileprivate lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.isUserInteractionEnabled = false
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
            let cover = UIImageView(image: self.imageView.image)
            cover.contentMode = .scaleAspectFill
            cover.isUserInteractionEnabled = true
            cover.frame = vc!.view.bounds
            vc!.view.addSubview(cover)
            self.dismiss(animated: false, completion: {
                let frame = self.dismissClosure!()
                if frame == CGRect.null {
                    return
                }
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                    cover.frame = frame
                }, completion: { (flag) in
                    cover.removeFromSuperview()
                })
            })
        }
        
         //面板的收藏/滤镜按钮
        panel.clickShare = { [weak self](sender) in
            self?.filter()
        }
         //面板的收藏按钮
        panel.clickFavorite = { [weak self](sender) in
            let button: UIButton = sender as! UIButton
            self?.handleFavorite(sender: button)
            }
         //面板的下载按钮
        panel.clickDownlaod = { [weak self](sender) in
            self?.download()
        }
        return panel
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        configUI()
        loadItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if panel.isHidden { // 防止动画位置的闪烁
            panel.isHidden = false
         }
        if !hasShowPanelAnimation && enablePanelAnimation {
            panel.flyFromBottomSpringAnimation()
            hasShowPanelAnimation = true
        }

        guideMask = GuideMaskView.mask(for: type(of: self), on: view, maskImages: ["guide_swipe_left"])
    }
    
    //添加手势
    private func addGesture() -> Void {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tap(_ :)))
        view.addGestureRecognizer(gesture)
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
    
    //调用系统的分享功能
    private func share() -> Void {
        let title: String = "home_share_app_title".localized
        let image: UIImage = imageView.image ?? UIImage(named: "default_placehold_s")!
//        let url: NSURL = NSURL(string: (imageInfo?.imgURL)!)!
        let items: Array = [title, image] as [Any]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact];
        vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            log.info("Share image"+(completed ? "Success" : "Failed"))
            vc.dismiss(animated: true, completion: {})
        }
        present(vc, animated: true) {}
    }
    
    //添加到收藏功能
    private func handleFavorite(sender: UIButton) -> Void {
        if isUndoFavorite {
            UserDefaultCache.shared.remove(object: imageInfo)
        } else {
            UserDefaultCache.shared.add(object: imageInfo)
        }
        isUndoFavorite = !isUndoFavorite
        sender.isSelected = isUndoFavorite
        SoundEffect.playSound(name: "BeepSelection03")
    }
    
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
    
    //使用第三方滤镜功能
    private func filter() {
        let imageToBeFiltered = imageView.image
        let vc = SHViewController(image: imageToBeFiltered!)
        vc.delegate = self
        self.present(vc, animated:true, completion: nil)
        SoundEffect.playSound(name: "FunnyVocal")
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
    
    //load
    private func loadItem() {
        if let info = imageInfo {
            setImageWithURL(info.imgURL!, thumbnail: info.thumbnail)
        }
    }
    
    // MARK: status bar
    override var prefersStatusBarHidden: Bool {
        get { return hiddenStatusBar }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return.lightContent }
    }
}

//上下滑动的扩展，可以切换不同的图片
extension PreviewViewController: SwipeScreenItemDelegate {
    static func itemRoomViewController(config: Any?) -> (SwipeScreenItemDelegate)? {
        let vc: PreviewViewController = self.init()
        if let config = config as? SwipeScreenContext {
            vc.enablePanelAnimation = config.isFirstScreen
        }
        return vc
    }
    
    func horizontalPanResponderView() -> UIView? {
        return previewView
    }
    
    func setItemDeltaX(_ delta: CGFloat, for view: UIView?, isBeganPan: Bool, isEndPan: Bool, beganOffsetX: CGFloat, completion: (() -> Void)?) -> Void {
        guideMask?.removeMask()
        if let v = view {
            let stepLen = v.bounds.width / 2
            var frame = v.frame
            let x = frame.origin.x + delta
            if x > stepLen || x < -2 * stepLen {
                return
            }
            frame.origin.x = x
            v.frame = frame
            if isBeganPan {
                panel.alpha = 0
            }
            
            if isEndPan {
                var target = frame
                let fromRightToLeft = beganOffsetX > x
                let fromLeftToRight = beganOffsetX < x
                if fromRightToLeft {
                    target.origin.x = beganOffsetX - stepLen
                } else if fromLeftToRight {
                    target.origin.x = beganOffsetX + stepLen
                }
                UIView.animate(withDuration: 0.35,
                               delay: 0,
                               usingSpringWithDamping: 0.95,
                               initialSpringVelocity: 0,
                               options: .curveEaseInOut,
                               animations: {
                    v.frame = target
                }) { (flag) in
                    let showPanel = v.frame.origin.x <= -2 * stepLen || v.frame.origin.x >= stepLen
                    self.panel.alpha = showPanel ? 1 : 0
//                    self.hiddenStatusBar = showPanel
                    if let closure = completion {
                        closure()
                    }
                }
            }
        }
    }
    
    func resetWhenInvalidPan() {
        panel.alpha = 1
    }
}

//滤镜的扩展
extension PreviewViewController: SHViewControllerDelegate {
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        self.imageView.image = image
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}
