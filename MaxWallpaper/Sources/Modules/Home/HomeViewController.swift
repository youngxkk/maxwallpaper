//
//  ViewController.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/2.
//  Copyright © 2018年 elijah. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import pop
import MJRefresh
import Kingfisher
import AudioToolbox


class HomeViewController: UIViewController {
    
    // MARK: property
    fileprivate var images: Array<ImageInfo>? = nil
    fileprivate var isMenuButtonAnimating: Bool = false
    fileprivate weak var menuView: SettingMenuView?
    
    fileprivate let pageSize: Int = 24
    fileprivate var page: Int = 0
    fileprivate var totalCount: Int = Int(INT_MAX)
    fileprivate var isFetchingData: Bool = false
    fileprivate var isFavoriteMode: Bool = false
    fileprivate var chosedIndexPath: IndexPath?
    fileprivate var transition: UIViewControllerAnimatedTransitioning?
    
    //左下角的 menu 菜单
    fileprivate lazy var menuButton: AnimationMenuButton = {
        let btn = AnimationMenuButton.init(
            frame: CGRect(x: 0, y: 0, width: 60, height: 60),
            normalIcon:"ic_menu",
            selectedIcon:"ic_close",
            buttonsCount: 4,
            duration: 4,
            distance: 120)
            btn.backgroundColor = HexColor(hex: 0xFF0073, alpha: 0.95) //4BCC21
            btn.layer.cornerRadius = btn.frame.size.width / 2.0
            btn.addTarget(self, action: #selector(type(of: self).didClickMenuButton(_ :)), for: .touchUpInside)
            return btn
    }()
    
    //右下角的收藏菜单
    fileprivate lazy var favoriteHomeButton: AnimationMenuButton = {
        let btn = AnimationMenuButton.init(
            frame: CGRect(x: 0, y: 0, width: 60, height: 60),
            normalIcon:"ic_favorite",
            selectedIcon:"ic_favorite",
            buttonsCount: 4,
            duration: 4,
            distance: 100)
        btn.backgroundColor = HexColor(hex: 0xFF0073, alpha: 0.95)
        
        btn.layer.cornerRadius = btn.frame.size.width / 2.0
        btn.addTarget(self, action: #selector(goFavoriteViewController), for: .touchUpInside)
        return btn
    }()
    
    
    //首页主要内容的布局
    fileprivate lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let imageViewWidth: CGFloat = (view.bounds.width - 4 ) / 2
        layout.itemSize = CGSize.init(width: imageViewWidth, height:imageViewWidth * 1.5)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }()
    
    //首页主要内容视图
    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.collectionViewLayout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.black
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        view.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
//        if #available(iOS 11, *) {
//            view.contentInsetAdjustmentBehavior = .never
//        }
        
        
        //下面与下拉刷新refresh相关
        let header = MJRefreshNormalHeader()
        header.ignoredScrollViewContentInsetTop = 15
        header.lastUpdatedTimeLabel.isHidden = true
        header.stateLabel.isHidden = true
        header.activityIndicatorViewStyle = .white
        header.refreshingBlock = { [weak self] in
            self?.fetchData(forward: true, compeletion: { isSuccess, hasMore in
                header.endRefreshing()
            })
            SoundEffect.playSound(name: "refresh")
            SoundEffect.vibrate(soundID: SystemSoundID(1519))
        }
        view.mj_header = header
        
        //上滑更新图片相关
        let footer = MJRefreshAutoFooter()
        footer.triggerAutomaticallyRefreshPercent = 0.0
        footer.refreshingBlock = { [weak self] in
            self?.fetchData(forward: false, compeletion: { isSuccess, hasMore in
                footer.endRefreshing() // 因为采用循环策略拉取 所以没有 footer.endRefreshingWithNoMoreData()
            })
        }
        view.mj_footer = footer
        
        return view
    }()
    
    
    // MARK: methods加载视图
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "home_page_home".localized
        configUI()
        fetchData(forward: true, compeletion: nil)
    }
    
    //UIViewController对象的视图即将加入窗口时调用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    //UIViewController对象的视图已经加入到窗口时调用
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK:界面的 UI 相关配置
    private func configUI() -> Void {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        //menu 按钮的尺寸和位置
        view.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.bottom.equalTo(-(18 + UIEdgeInsets.systemSafeArea().bottom))
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        
        //收藏按钮的尺寸和位置
        view.addSubview(favoriteHomeButton)
        favoriteHomeButton.snp.makeConstraints { (make) in
            make.right.equalTo(-18)
            make.bottom.equalTo(menuButton.snp.bottom)
            make.size.equalTo(menuButton.snp.size)
        }
    }
    
    //点击 menu 按钮触发的行为
    @objc private func didClickMenuButton(_ sender: UIButton!) -> Void {
        let animspring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        animspring?.fromValue = CGSize(width: 0.5, height: 0.5)
        animspring?.toValue = CGSize(width: 1.0, height: 1.0)
        animspring?.springSpeed = 20
        animspring?.springBounciness = 12
//        animspring?.dynamicsMass = 1
        
        if self.menuView != nil {
            self.menuView!.removeFromSuperview()
            return
        }
        
        //menu 菜单弹出的3个功能
        let menuView = SettingMenuView()
        menuView.selectCallback = { (idx) in
            self.menuButton.onTap()     //复位
            if 0 == idx {
                SoundEffect.playSound(name: "tap")
                let sendMailHelper = SendMailHelper()
                let viewController = sendMailHelper.basicConfigAndShowMail(recipients: ["maxwallpaperapp@gmail.com"], subject: "home_feedback_mail_subject".localized, messageBody: "")
                if let vc = viewController {
                    sendMailHelper.setCcRecipients([""])
                    self.present(vc, animated: true, completion: {})
                }
            } else if 1 == idx {
                SoundEffect.playSound(name: "tap")
                let SettingVC = SettingViewController()
                self.navigationController?.pushViewController(SettingVC, animated: true)
            } else if 2 == idx {
                SoundEffect.playSound(name: "tap")
                func share() -> Void {
                    let title: String = "home_share_app_title".localized
                    let img = UIImage(named: "icon-60@3x.png")
                    let imageView = UIImageView(image: img)
                    let url: NSURL = NSURL(string: "https://itunes.apple.com/cn/app/id1420435738")! // 已替换成自己的appid
                    let items: Array = [title, imageView, url] as [Any]
                    let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
                        log.info("share app"+(completed ? "success" : "failed"))
                        vc.dismiss(animated: true, completion: {})
                    }
                    self.present(vc, animated: true) {}
                }
                share()
            } 
        }
        menuView.pop_add(animspring, forKey: "scale")
        self.menuView = menuView
        view.addSubview(menuView)
        menuView.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.bottom.equalTo(menuButton.snp.top).offset(-18)
            make.size.equalTo(SettingMenuView.recommendSize)
        }
        SoundEffect.playSound(name: "click")
        SoundEffect.vibrate(soundID: SystemSoundID(1519))
    }

    
    //跳转到收藏单独的界面
    @objc func goFavoriteViewController() {
        let fvc = FavoriteViewController()
        SoundEffect.playSound(name: "Tab2")
        SoundEffect.vibrate(soundID: SystemSoundID(1519))
        self.navigationController?.pushViewController(fvc, animated: true)
    }
        
    //获取当前页面的数据
    private func fetchData(forward: Bool, compeletion: ((_ isSuccess: Bool, _ hasMore: Bool) -> Void)?) -> Void {
        if isFetchingData {
            return
        }
        isFetchingData = true
        
        func newPage(_ forward: Bool, currentPage: Int) -> Int {
            if currentPage == Int(INT_MAX) || totalCount == Int(INT_MAX) {
                return 1
            }
            let cp = forward ? currentPage - 1 : currentPage + 1
            if cp < 1 {
                return Int((arc4random() % UInt32(totalCount / pageSize)) + 1)
            }
            return cp
        }
        page = newPage(forward, currentPage: page)
        
        ImageInfo.fetchImageList(page: page, pageSize: pageSize) { (error, code, newData, hasMore, totalCount) in
            if error == nil, let data = newData, code == .success {
                if self.totalCount == Int(INT_MAX) {
                    self.totalCount = totalCount;
                    self.page = Int((arc4random() % UInt32(totalCount / self.pageSize)) + 1)
                    self.isFetchingData = false
                    self.fetchData(forward: forward, compeletion: compeletion)
                    return
                }
                
                self.page = hasMore ? self.page : Int(INT_MAX)
                self.totalCount = totalCount
                if forward {
                    self.images = data
                } else {
                    if !(newData?.isEmpty)! {
                        self.images = self.images == nil ? data : self.images! + data
                    }
                }
                
                self.collectionView.reloadData()
                
                if let closure = compeletion {
                    closure(true, hasMore)
                }
            } else {
                var msg: String = "network_req_no_data".localized
                if code == .limited {
                    msg = "network_req_limited".localized
                } else if code == .noData {
                    msg = "network_req_failure".localized
                }
                HUDTool.show(msg: msg)
                if let closure = compeletion {
                    closure(false, forward ? true : false)
                }
            }
            self.isFetchingData = false
        }
    }
    
    //单击缩略图后放大
    fileprivate func showDisplayViewController(indexPath: IndexPath) -> Void {
        if menuButton.isShow {
            menuButton.onTap()
            menuView?.removeFromSuperview()
        }
        let vc = DisplayViewController()
        vc.imageInfos = self.images
        vc.currentIdx = indexPath.item
        vc.swipeScreenContext.firstScreenThumnailImage = (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).currentImage()
        vc.dismissClosure = { idx in
            let idxPath = IndexPath(item: idx, section: indexPath.section)
            self.collectionView.scrollToItem(at: idxPath, at: .centeredVertically, animated: false)
            let frame = self.collectionView.convert((self.collectionView.layoutAttributesForItem(at: idxPath)?.frame)!, to: self.view)
            return frame
        }
        vc.updateImageInfos = { [weak vc] in
            self.fetchData(forward: false, compeletion: { (isSuccess, hasMore) in
                if (isSuccess) {
                    self.collectionView.reloadData()
                    vc?.imageInfos = self.images
                }
            })
        }
        chosedIndexPath = indexPath
        vc.transitioningDelegate = self
        self.present(vc, animated: true) {
        
        }
    }
    
    // MARK: status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return.lightContent }
    }
    
    //数据为空的时候
    private func emptyView() -> Void {
        let emptyTitleLabel = UILabel()
        let emptyDetailLabel = UILabel()
        let mainButton = UIButton()
        
        //点击刷新的按钮 btn
        mainButton.frame.size = CGSize(width: 120, height: 45)
        mainButton.center.x = self.view.bounds.width / 2
        mainButton.center.y = self.view.bounds.height - 200
        mainButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        mainButton.setTitle("empty_refresh".localized, for: .normal)
        mainButton.setTitleColor(UIColor.white, for: .normal)
        mainButton.backgroundColor = HexColor(hex: 0xFF0073, alpha: 1.0)
        mainButton.adjustsImageWhenHighlighted = false
        self.view.addSubview(mainButton)
//        mainButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        //空状态的标题
        emptyTitleLabel.text = "empty_title".localized
        emptyTitleLabel.textColor = UIColor.white
        emptyTitleLabel.font = UIFont.systemFont(ofSize: 22)
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.frame.size = CGSize(width: self.view.bounds.width * 0.8 , height: 40)
        emptyTitleLabel.frame.origin.x = (self.view.bounds.width - (self.view.bounds.width * 0.8))/2
        emptyTitleLabel.frame.origin.y = self.view.bounds.height * 0.4
        emptyTitleLabel.adjustsFontSizeToFitWidth = true
        emptyTitleLabel.minimumScaleFactor = 0.6
        self.view.addSubview(emptyTitleLabel)
        
        //空状态的内容
        emptyDetailLabel.text = "empty_content".localized
        emptyDetailLabel.textColor = UIColor.white
        emptyDetailLabel.font = UIFont.systemFont(ofSize: 14)
        emptyDetailLabel.textAlignment = .center
        emptyDetailLabel.frame.size = CGSize(width: self.view.bounds.width * 0.88 , height: 80)
        emptyDetailLabel.frame.origin.x = (self.view.bounds.width - (self.view.bounds.width * 0.88))/2
        emptyDetailLabel.frame.origin.y = self.view.bounds.height * 0.46
        emptyDetailLabel.lineBreakMode = .byWordWrapping
        emptyDetailLabel.numberOfLines = 0
        emptyDetailLabel.adjustsFontSizeToFitWidth = true
        emptyDetailLabel.minimumScaleFactor = 0.6
        self.view.addSubview(emptyDetailLabel)
    }
    
    
}

//首页 ViewController 功能的扩展
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource收集视图返回图片编号
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imgs = images {
            return imgs.count;
        }
        return 0;
    }
    
    //首页预览图使用原图或者 webp 格式的缩略图
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self), for: indexPath) as! ImageCollectionViewCell
        
        let idx: Int = indexPath.item
        cell.setImageURL(images![idx].thumbnail!)  //修改首页预览图的位置,小图片是thumbnail，原图片是imgURL
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imgs = images {
            if indexPath.item < imgs.count {
                showDisplayViewController(indexPath: indexPath)
            }
        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = ScalePresentAnimator()
        if chosedIndexPath != nil {
            animation.originFrame = collectionView.convert((collectionView.layoutAttributesForItem(at: chosedIndexPath!)?.frame)!, to: view)
        }
        transition = animation
        return animation
    }
}
