//
//  SwipeScreenItemDelegate.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/7.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

// 划屏承载的实际内容，必须实现这个协议，类似于UITabelViewCell这个基类
// MARK: required
protocol SwipeScreenItemDelegate {
    /// 获取划屏实例的委托方法
    ///
    /// - Parameter config: 业务自定义的配置信息，可以使用自定义的类或者与业务无关的容器类等
    /// - Returns: 划屏的实例item
    static func itemRoomViewController(config: Any?) -> (SwipeScreenItemDelegate)?
    
    
    // MARK: optional
    /// 当前item销毁直播等工作的委托
    func itemDestoryWork() -> Void
    
    /// 获取item内响应竖直滑动手势的视图, 若不实现则默认为itemViewController.view
    ///
    /// - Returns: 响应竖直滑动手势的视图
    func verticalPanResponderView() -> UIView!
    
    /// 设置竖直滑动视图的附加动作，滑动已经由内部处理
    ///
    /// - Parameters:
    ///   - delta: 偏移量的值
    ///   - view: 即verticalPanResponderView，便于使用
    ///   - isEndPan: 是不是手势结束
    ///   - completion: 手势在结束时的回调
    func setItemDeltaY(_ delta: CGFloat, for view: UIView?, isEndPan: Bool, completion: (() -> Void)?) -> Void
    
    /// 当前item能不能响应划屏事件
    ///
    /// - Parameter gesture: 处理的手势
    /// - Returns: true为可以，false为不可以
    func shouldBegan(_ gesture: UIGestureRecognizer?) -> Bool
    
    /// 当前item能不能透传touch事件
    ///
    /// - Parameter touch: 处理的手势的触摸
    /// - Returns: true为可以，false为不可以
    func shouldReceive(_ touch: UITouch?) -> Bool
    
    /// 获取item内响应水平滑动手势的视图
    ///
    /// - Returns: 响应水平滑动手势的视图
    func horizontalPanResponderView() -> UIView?
    
    /// 设置竖直滑动视图的动作，需要外部自己处理响应相应视图的偏移量
    ///
    /// - Parameters:
    ///   - delta: 偏移量的值
    ///   - view: 即horizontalPanResponderView，便于使用
    ///   - isEnd: 是不是手势结束
    ///   - beganOffsetX: 对应于一次滑动的响应水平滑动视图的起始位置
    ///   - completion: 手势在结束时的回调
    func setItemDeltaX(_ delta: CGFloat, for view: UIView?, isBeganPan: Bool, isEndPan: Bool, beganOffsetX: CGFloat, completion: (() -> Void)?) -> Void
    
    /// 无效滑动时的回调
    ///
    /// - Returns: 无返回值
    func resetWhenInvalidPan() -> Void
    
    // MARK: 以下委托方法给item提供在内部更改划屏浮窗的能力
    
    /// 如果有需要的话 提供浮动挂件的frame
    ///
    /// - Returns: 挂件的frame
    func appdentViewFrame() -> CGRect
    
    /// 提供item内部浮窗视图的view controller，优先级高于下面的appdentView
    ///
    /// - Returns: 浮窗视图的view controller
    func appdentViewContrller() -> UIViewController?
    
    /// 提供直播间内部划屏浮窗视图的view，优先级低于上面的appdentViewContrller
    ///
    /// - Returns: 浮窗视图的view
    func appdentView() -> UIView?
}

// MARK: optional
extension SwipeScreenItemDelegate where Self: UIViewController {
    /// 当前item销毁直播等工作的委托
    func itemDestoryWork() -> Void {}
    
    /// 获取item内响应竖直滑动手势的视图, 若不实现则默认为itemViewController.view
    ///
    /// - Returns: 响应竖直滑动手势的视图
    func verticalPanResponderView() -> UIView! {
        return self.view
    }
    
    /// 设置竖直滑动视图的附加动作，滑动已经由内部处理
    ///
    /// - Parameters:
    ///   - delta: 偏移量的值
    ///   - view: 即verticalPanResponderView，便于使用
    ///   - isEndPan: 是不是手势结束
    func setItemDeltaY(_ delta: CGFloat, for view: UIView?, isEndPan: Bool, completion: (() -> Void)?) -> Void {
        if let closure = completion {
            closure()
        }
    }
    
    /// 当前item能不能响应划屏事件
    ///
    /// - Parameter gesture: 处理的手势
    /// - Returns: true为可以，false为不可以
    func shouldBegan(_ gesture: UIGestureRecognizer?) -> Bool {
        return true
    }
    
    /// 当前item能不能透传touch事件
    ///
    /// - Parameter touch: 处理的手势的触摸
    /// - Returns: true为可以，false为不可以
    func shouldReceive(_ touch: UITouch?) -> Bool {
        return true
    }
    
    /// 获取item内响应水平滑动手势的视图
    ///
    /// - Returns: 响应水平滑动手势的视图
    func horizontalPanResponderView() -> UIView? {
        return nil
    }
    
    /// 设置竖直滑动视图的动作，需要外部自己处理响应相应视图的偏移量
    ///
    /// - Parameters:
    ///   - delta: 偏移量的值
    ///   - view: 即horizontalPanResponderView，便于使用
    ///   - isEnd: 是不是手势结束
    ///   - beganOffsetX: 对应于一次滑动的响应水平滑动视图的起始位置
    func setItemDeltaX(_ delta: CGFloat, for view: UIView?, isBeganPan: Bool, isEndPan: Bool, beganOffsetX: CGFloat, completion: (() -> Void)?) -> Void {
        if let closure = completion {
            closure()
        }
    }
    
    /// 无效滑动时的回调
    ///
    /// - Returns: 无返回值
    func resetWhenInvalidPan() -> Void {}
    
    // MARK: 以下委托方法给item提供在内部更改划屏浮窗的能力
    
    /// 如果有需要的话 提供浮动挂件的frame
    ///
    /// - Returns: 挂件的frame
    func appdentViewFrame() -> CGRect {
        return CGRect.zero
    }
    
    /// 提供item内部浮窗视图的view controller，优先级高于下面的appdentView
    ///
    /// - Returns: 浮窗视图的view controller
    func appdentViewContrller() -> UIViewController? {
        return nil
    }
    
    /// 提供直播间内部划屏浮窗视图的view，优先级低于上面的appdentViewContrller
    ///
    /// - Returns: 浮窗视图的view
    func appdentView() -> UIView? {
        return nil
    }
}
