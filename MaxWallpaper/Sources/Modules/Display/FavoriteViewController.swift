//
//  FavoriteViewController.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/9/19.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import AudioToolbox
import Kingfisher


class FavoriteViewController: UIViewController {
    
    // MARK: property
    fileprivate var images: Array<ImageInfo>? = nil
    
    fileprivate let pageSize: Int = 24
    fileprivate var page: Int = 0
    fileprivate var totalCount: Int = 200
    fileprivate var isFetchingData: Bool = false
    fileprivate var isFavoriteMode: Bool = false
    fileprivate var chosedIndexPath: IndexPath?
    fileprivate var transition: UIViewControllerAnimatedTransitioning?

    //页面布局相关
    fileprivate lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let imageViewWidth: CGFloat = (self.view.bounds.width - 4 ) / 2
        layout.itemSize = CGSize.init(width: imageViewWidth, height:imageViewWidth * 1.5)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
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
        return view
    }()
    
    // 重写当前页面启动之前加载的方法
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    //页面即将加载之前执行
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // 页面的 UI 配置相关
    private func configUI() -> Void {
        self.title = "home_page_favorite".localized
        fetchData(forward: true, compeletion: nil)
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
    //收藏的数据的方法
    @discardableResult
    open func fetchFavoriteData() -> [ImageInfo]! {
        return UserDefaultCache.shared.objects() ?? []
    }
    
    //获取数据
    private func fetchData(forward: Bool, compeletion: ((_ isSuccess: Bool, _ hasMore: Bool) -> Void)?) -> Void {
        images = fetchFavoriteData()
        collectionView.reloadData()
        if let closure = compeletion {
            closure(true, false)
        }

    }
    
    @objc func refreshFavorite(_ sender: UIButton) -> Void {
        let nextIsFavoriteMode: Bool = !isFavoriteMode
        if !nextIsFavoriteMode {
            navigationItem.title = "home_page_home".localized
            isFavoriteMode = nextIsFavoriteMode
            fetchData(forward: true, compeletion: nil)
        } else {
            let favoriteImages: [ImageInfo]? = fetchFavoriteData()
            if (favoriteImages == nil || favoriteImages!.isEmpty) {
                HUDTool.show(msg: "no_favorite_images".localized)
            }
        }
        SoundEffect.playSound(name: "click")
        SoundEffect.vibrate(soundID: SystemSoundID(1519))
    }
    
    //重写 status bar 变成亮色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return.lightContent }
    }
}

//FavoriteViewController的扩展，
extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        if let images = images {
            if idx < images.count {
                cell.setImageURL(images[idx].thumbnail!)  //修改首页预览图的位置,小图片是thumbnail，原图片是imgURL
            }
        }
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

extension FavoriteViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = ScalePresentAnimator()
        if chosedIndexPath != nil {
            animation.originFrame = collectionView.convert((collectionView.layoutAttributesForItem(at: chosedIndexPath!)?.frame)!, to: view)
        }
        transition = animation
        return animation
    }
}
