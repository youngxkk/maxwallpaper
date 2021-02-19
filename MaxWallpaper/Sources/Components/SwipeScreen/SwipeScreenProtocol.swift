//
//  SwipeScreenProtocol.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/7.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

/**
 方向的枚举类型，外部使用建议只用于水平还是竖直方向的判断，不要作为其他判断的依据
 */
enum PanDirection: Int {
    case unknown
    case up
    case left
    case down
    case right
}


// MARK: required SwipeScreenDelegate
protocol SwipeScreenDelegate: AnyObject {
    /// 在划屏组件之间传递的上下文变量，用于传递状态，由业务自定
    var globalContext: Any? { get set }
    
    // MARK: optional
    //MARK: 手势响应部分
    
    /// 划屏手势开始
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 滑动的方向
    func swipeViewController(_ swipeVC: UIViewController?, began gesture: UIGestureRecognizer?, direction: PanDirection) -> Void
    
    /// 划屏手势结束
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 滑动的方向
    func swipeViewController(_ swipeVC: UIViewController?, end gesture: UIGestureRecognizer?, direction: PanDirection) -> Void
    
    /// 划屏触发的偏移量回调
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 触发划屏的手势
    ///   - delta: 当前的偏移量的delta值
    func swipeViewController(_ swipeVC: UIViewController?, gesture: UIGestureRecognizer?, direction: PanDirection, delta: CGFloat) -> Void
    
    // MARK: - 快速划动部分
    
    /// 返回快速划屏的步长
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - step: 划过的步长，负数表示向前划，正数表示向后划
    ///   - direction: 滑动方向
    func swipeViewController(_ swipeVC: UIViewController?, fast step: Int, direction: PanDirection) -> Void
    
    /// 在reloadItem之前调用. 为划屏做好准备，防止出现背景图错乱等等一些划动重用的情况
    ///
    /// - Parameters:
    ///   - swipVC: 划屏所属的控制器
    ///   - previousView: 前一个背景容器, 不要直接操作preView, 重用时 请处理他的subview
    ///   - nextView: 下一个背景容器, 不要直接操作preView, 重用时 请处理他的subview
    func prepareForSwipe(in swipVC: UIViewController?, previousView: UIView?, nextView: UIView?) -> Void
}

// MARK: optional SwipeScreenDelegate
extension SwipeScreenDelegate {
    //MARK: 手势响应部分
    
    /// 划屏手势开始
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 滑动的方向
    func swipeViewController(_ swipeVC: UIViewController?, began gesture: UIGestureRecognizer?, direction: PanDirection) -> Void {}
    
    /// 划屏手势结束
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 滑动的方向
    func swipeViewController(_ swipeVC: UIViewController?, end gesture: UIGestureRecognizer?, direction: PanDirection) -> Void {}
    
    /// 划屏触发的偏移量回调
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - gesture: 触发划屏的手势
    ///   - direction: 触发划屏的手势
    ///   - delta: 当前的偏移量的delta值
    func swipeViewController(_ swipeVC: UIViewController?, gesture: UIGestureRecognizer?, direction: PanDirection, delta: CGFloat) -> Void {}
    
    // MARK: - 快速划动部分
    
    /// 返回快速划屏的步长
    ///
    /// - Parameters:
    ///   - swipeVC: 所属的划屏控制器
    ///   - step: 划过的步长，负数表示向前划，正数表示向后划
    ///   - direction: 滑动方向
    func swipeViewController(_ swipeVC: UIViewController?, fast step: Int, direction: PanDirection) -> Void {}
    
    /// 在reloadItem之前调用. 为划屏做好准备，防止出现背景图错乱等等一些划动重用的情况
    ///
    /// - Parameters:
    ///   - swipVC: 划屏所属的控制器
    ///   - previousView: 前一个背景容器, 不要直接操作preView, 重用时 请处理他的subview
    ///   - nextView: 下一个背景容器, 不要直接操作preView, 重用时 请处理他的subview
    func prepareForSwipe(in swipVC: UIViewController?, previousView: UIView?, nextView: UIView?) -> Void {}
}

// MARK: required SwipeScreenDataSource
protocol SwipeScreenDataSource: AnyObject {
    
    /// 划屏呈现的内容控制器
    ///
    /// - Parameter swipeVC: 所属的划屏控制器
    /// - Returns: 要呈现的控制器
    func itemViewController(_ swipeVC: UIViewController?) -> (SwipeScreenItemDelegate)?
    
    
    /// 获取当前的数据源个数
    ///
    /// - Returns: 返回的数据原个数
    func itemCount() -> Int
    
    
    /// 上下划屏时的上下视图的背景视图设置
    ///
    /// - Parameters:
    ///   - previousView: 上一个背景视图的容器视图
    ///   - nextView: 下一个背景视图的容器视图
    func background(previousView: UIView?, nextView: UIView?) -> Void
    
    
    
    // MARK: optional SwipeScreenDataSource
    /// 快速划屏时的背景视图设置
    ///
    /// - Parameter view: 快速划屏的背景视图容器视图
    func fastSwipeBackground(_ view: UIView?) -> Void
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldReceive touch: UITouch?, direction: PanDirection) -> Bool
}

// MARK: optional SwipeScreenDataSource
extension SwipeScreenDataSource {
    /// 快速划屏时的背景视图设置
    ///
    /// - Parameter view: 快速划屏的背景视图容器视图
    func fastSwipeBackground(_ view: UIView?) -> Void {}
    /// 在手势识别开始之前，判断是不是要忽略这种情况的手势识别
    /// swipeVC 所属的划屏控制器
    /// gestureRecognizer 触发划屏的手势
    /// direction 划动方向
    /// return 是不是忽略，true为忽略，false为继续识别
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool {
        return true
    }
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool {
        return false
    }
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer?, direction: PanDirection) -> Bool {
        return false
    }
    
    func swipeViewControlelr(_ swipeVC: UIViewController?, gestureRecognizer: UIGestureRecognizer?, shouldReceive touch: UITouch?, direction: PanDirection) -> Bool {
        return true
    }
}


// MARK: required SwipeScreenDataSource
protocol SwipeScreenDataPrefetching: AnyObject {
    
    // MARK: optional SwipeScreenDataSource
    /// 提供给外部在划屏动画之前做数据预加载的机会，注意这个方法已经派发到了后台线程
    ///
    /// - Parameter step: 划过的步长, -1 表示向前一个  1表示向后一个
    func itemPrefetchData(withStep step: Int) -> Void
}
// MARK: optional SwipeScreenDataSource
extension SwipeScreenDataPrefetching {
    /// 提供给外部在划屏动画之前做数据预加载的机会，注意这个方法已经派发到了后台线程
    ///
    /// - Parameter step: 划过的步长, -1 表示向前一个  1表示向后一个
    func itemPrefetchData(withStep step: Int) -> Void {}
}
