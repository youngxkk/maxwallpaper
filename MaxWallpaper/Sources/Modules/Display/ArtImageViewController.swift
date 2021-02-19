//
//  ArtImageViewController.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/10/8.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import AudioToolbox
import MJRefresh
import Kingfisher


class ArtImageViewController: UIViewController {
    
    // MARK: property
    fileprivate var images: Array<ImageInfo>? = nil
    fileprivate let pageSize: Int = 24
    fileprivate var page: Int = 0
    fileprivate var totalCount: Int = Int(INT_MAX)
    fileprivate var isFetchingData: Bool = false
    fileprivate var chosedIndexPath: IndexPath?
    fileprivate var transition: UIViewControllerAnimatedTransitioning?
    
    //页面布局相关
    fileprivate lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let imageViewWidth: CGFloat = (self.view.bounds.width - 3 ) / 2
        layout.itemSize = CGSize.init(width: imageViewWidth, height:imageViewWidth * 1.5)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }()
    
    //页面布局2
    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.collectionViewLayout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.black
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        view.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
        
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
        
        //上拉刷新图片
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
    
    // 重写当前页面启动之前加载的方法
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        page = Int(INT_MAX)
        fetchData(forward: true, compeletion: nil)
    }
    
    //页面即将加载之前执行
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // 页面的 UI 配置相关
    private func configUI() -> Void {
        self.title = "Art_image_title".localized
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    //点击预览图变成大图的转场动画效果
    fileprivate func showDisplayViewController(indexPath: IndexPath) -> Void {
        navigationController?.navigationBar.isHidden = true
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
    
    //获取数据
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
        
        ImageInfo.fetchImageList(page: page, pageSize: pageSize, isEasterEgg: true) { [weak self](error, code, newData, hasMore, totalCount) in
            guard let self = self else { return }
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
                if self.images?.count ?? 0 > 0 {
                    self.collectionView.reloadData()
                } else {
                    HUDTool.show(msg: "network_no_easter_egg_data".localized, durationBase: 2)
                }
            
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
    
    //重写 status bar 变成亮色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return.lightContent }
    }
}

//BeautyViewController的扩展
extension ArtImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imgs = images {
            return imgs.count;
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self), for: indexPath) as! ImageCollectionViewCell
        
        let idx: Int = indexPath.item
        cell.setImageURL(images![idx].imgURL!)  //修改首页预览图的位置,小图片是thumbnail，原图片是imgURL
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

extension ArtImageViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = ScalePresentAnimator()
        if chosedIndexPath != nil {
            animation.originFrame = collectionView.convert((collectionView.layoutAttributesForItem(at: chosedIndexPath!)?.frame)!, to: view)
        }
        transition = animation
        return animation
    }
}
