//
//  OperationPanelView.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/10.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

typealias clickClosure = (_ sender: Any) -> Void

class OperationPanel: UIView {
    static let minPanelHeight: CGFloat = 40
    
    var clickBack: clickClosure?
    var clickShare: clickClosure?
    var clickFavorite: clickClosure?
    var clickDownlaod: clickClosure?
    
    fileprivate lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "ic_pic_back"), for: .normal)
        btn.addTarget(self, action: #selector(back(_ :)), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var shareButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "ic_pic_share"), for: .normal)
        btn.addTarget(self, action: #selector(share(_ :)), for: .touchUpInside)
        return btn
    }()
    
//    public lazy var favoriteButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.setBackgroundImage(UIImage(named: "ic_pic_favorite"), for: .normal)
//        btn.setBackgroundImage(UIImage(named: "ic_pic_favorite_enable"), for: .selected)
//        btn.addTarget(self, action: #selector(favorite(_ :)), for: .touchUpInside)
//        return btn
//    }()
    
    public lazy var favoriteButton: AnimationMenuButton = {
        let btn = AnimationMenuButton.init(
            frame: CGRect(x: 0, y: 0, width: 60, height: 60),
            normalIcon:"ic_pic_favorite",
            selectedIcon:"ic_pic_favorite_enable",
            buttonsCount: 4,
            duration: 4, //持续时间
            distance: 100)
        btn.layer.cornerRadius = btn.frame.size.width / 2.0
        btn.addTarget(self, action: #selector(type(of: self).favorite(_ :)), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var downloadButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "ic_pic_download"), for: .normal)
        btn.addTarget(self, action: #selector(download(_ :)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() -> Void {
 
        let spaceWidth:CGFloat = (screenWidth - 240) / 5
        
        addSubview(backButton)
        addSubview(shareButton)
        addSubview(favoriteButton)
        addSubview(downloadButton)
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(spaceWidth)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(spaceWidth)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.right.equalTo(downloadButton.snp.left).offset(-spaceWidth)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        
        downloadButton.snp.makeConstraints { (make) in
            make.right.equalTo(-spaceWidth)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
    }
    
    @objc private func back(_ sender: UIButton) -> Void {
        if let closure = clickBack {
            closure(sender)
        }
    }
    
    @objc private func share(_ sender: UIButton) -> Void {
        if let closure = clickShare {
            closure(sender)
        }
    }
    
    @objc private func favorite(_ sender: UIButton) -> Void {
        if let closure = clickFavorite {
            closure(sender)
            
        }
    }
    
    @objc private func download(_ sender: UIButton) -> Void {
        if let closure = clickDownlaod {
            closure(sender)
        }
    }
    
    // MARK: animation
    fileprivate func springAnimation(to view: UIView!, beginTime: TimeInterval) -> Void {
        let springAnim = CASpringAnimation(keyPath: "position.y")
        springAnim.beginTime = CACurrentMediaTime() + beginTime  //3个按钮动画的延迟时间不一样
        springAnim.fromValue = view.layer.position.y + 120
        springAnim.toValue = view.layer.position.y
        springAnim.duration = springAnim.settlingDuration   //动画时间
        springAnim.mass = 0.9  //刚度系数(弹性系数)，越大形变产生的力就越大，运动越快
        springAnim.stiffness = 240  //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
        springAnim.damping = 18.0  //初始速度 默认0
        springAnim.initialVelocity = 0  //速率为正数时，速度方向与运动方向一致，速率为负数时速度方向相反
        springAnim.isRemovedOnCompletion = true    //动画结束保持最终状态
        springAnim.delegate = self as? CAAnimationDelegate
        springAnim.fillMode = CAMediaTimingFillMode.backwards
        view.layer.add(springAnim, forKey: "anykey")
    }
    
    func flyFromBottomSpringAnimation() -> Void {
        springAnimation(to: backButton, beginTime: 0.0)
        springAnimation(to: shareButton, beginTime: 0.08)
        springAnimation(to: favoriteButton, beginTime: 0.16)
        springAnimation(to: downloadButton, beginTime: 0.24)
    }
}
