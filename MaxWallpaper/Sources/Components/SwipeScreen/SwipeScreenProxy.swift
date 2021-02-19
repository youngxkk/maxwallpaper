//
//  SwipeScreenProxy.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/7.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

class SwipeScreenProxy: NSObject {
    // MARK: 以下四个要弱引用
    private weak var delegate: SwipeScreenDelegate!
    private weak var dataSource: SwipeScreenDataSource!
    private weak var dataPrefetching: SwipeScreenDataPrefetching!
    private(set) weak var container: (UIViewController & SwipeScreenDelegate & SwipeScreenDataSource & SwipeScreenDataPrefetching)!
    
    private(set) var currentItem: SwipeScreenItemDelegate?

    /// 控制器的背景视图，默认为nil，可用于设置快速划屏的与控制器等大的背景图等。
    var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
        }
        didSet {
            if backgroundView != nil {
                backgroundView!.frame = container.view.bounds
                container.view.insertSubview(backgroundView!, at: 0)
            }
        }
    }
    
    /// 快速划屏的限制阈值，默认200ms，阈值以内的划屏速度 将不会做任何操作，只显示背景 即backgroundView,该时长必须大于animationDuration
    var fastSwipeThreshold: TimeInterval = 200.0
    
    /// 触发水平滑动响应的有效距离，超过这个距离认为滑动结果有效，默认为60
    var validOffsetX: CGFloat = 60.0
    
    /// 触发竖直滑动响应的有效距离，超过这个距离认为滑动结果有效，默认为80
    var validOffsetY: CGFloat = 80.0
    
    /// 有效触发划屏之后的过渡动画时长，默认0.25s
    var animationDuration: TimeInterval = 0.25
    
    /// 浮窗
    var appdendView: UIView? {
        willSet {
            appdendView?.removeFromSuperview()
        }
        didSet {
            if appdendView != nil {
                container.view.addSubview(appdendView!)
            }
        }
    }
    
    /// 是否允许appdendView 随着划屏移动，默认为no
    var allowAppdendViewFollowPan = false
    
    private var pan: UIPanGestureRecognizer?
    private var currentPanDirection: PanDirection = .unknown
    private var beganOffsetX: CGFloat = 0.0
    private var horizontalViewOriginalFrame = CGRect.zero
    private var verticalViewOriginalFrame = CGRect.zero
    private var appendViewOriginalFrame = CGRect.zero
    private var lastPanTimestamp: TimeInterval = 0.0
    private var fastSwipeStep: Int = 0
    private var isContinuouslyFastSwipe = false
    private var previousView: UIView?
    private var nextView: UIView?
    
    init(container: (UIViewController & SwipeScreenDelegate & SwipeScreenDataSource & SwipeScreenDataPrefetching)!) {
        super.init()
        self.container = container
        delegate = container;
        dataSource = container
        dataPrefetching = container
        addPanGesture()
    }
    
    // MARK: internal methods
    /// 用于刷新item
    func reloadItems() {
        prepareItems()
        
        delegate.prepareForSwipe(in: container, previousView: previousView, nextView: nextView)
        
        dataSource.background(previousView: previousView, nextView: nextView)
        // 记录原始frame，为划屏方向判断提供依据
        appendViewOriginalFrame = CGRect.zero
        if allowAppdendViewFollowPan && appdendView != nil  {
            appendViewOriginalFrame = appdendView!.frame
        }
        horizontalViewOriginalFrame = CGRect.zero
        if let view = currentItem?.horizontalPanResponderView() {
            horizontalViewOriginalFrame = view.frame
        }
        
        verticalViewOriginalFrame = CGRect.zero
        if let view = currentItem?.verticalPanResponderView() {
            verticalViewOriginalFrame = view.frame
        }
    }
    
    func reloadItem(_ position: Int) -> Void {
        
    }
    
    /// 向前或向后滑动到一个新的item
    ///
    /// - Parameters:
    ///   - direction: 滑动方向，只支持up和down两个方向
    ///   - completion: 滑动完成的回调
    func scrollToNewItem(direction: PanDirection, completion: (() -> Void)? = nil) {
        assert(direction == .up || direction == .down, "Invalid parameter not satisfying: direction == .up || direction == .down")
        swipeAndShow(gesture: nil, direction: direction, completion: completion)
    }
    
    
    // MARK: private methods
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self as UIGestureRecognizerDelegate
        container.view.addGestureRecognizer(panGesture)
        pan = panGesture
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if currentItem == nil {
            return
        }
        var translation: CGPoint = gesture.translation(in: container.view)
        switch gesture.state {
        case .began:
            assert(currentItem!.verticalPanResponderView().bounds.width > validOffsetY, "有效滑动距离小于响应视图的尺寸")
            let isHorizontal: Bool = .left == currentPanDirection || .right == currentPanDirection
            let horizontalView: UIView? = currentItem!.horizontalPanResponderView()
            if isHorizontal {
                if let view = horizontalView {
                    beganOffsetX = view.frame.origin.x
                }
                currentItem!.setItemDeltaX(translation.x, for: horizontalView, isBeganPan: true, isEndPan: false, beganOffsetX: beganOffsetX, completion: nil)
            } else {
                currentItem!.setItemDeltaY(translation.y, for: currentItem!.verticalPanResponderView(), isEndPan: false, completion: nil)
            }
            delegate.swipeViewController(container, began: gesture, direction: currentPanDirection)
        case .changed:
            var isVertical = false
            currentPanDirection = nextDirection(previousDirection: currentPanDirection)
            if .up == currentPanDirection || .down == currentPanDirection {
                isVertical = true
                translation.x = 0 // 屏蔽掉不同方向的偏移量
            } else if .left == currentPanDirection || .right == currentPanDirection {
                isVertical = false
                translation.y = 0
            }
            let currentOffset = panOffset(isVertical: isVertical)
            if currentOffset == CGFloat.infinity { // 容错
                resetItemsPostion()
                return
            }
            if isVertical { // 竖直方向
                let view: UIView! = currentItem!.verticalPanResponderView()
                let height = view.bounds.height
                let y: CGFloat = currentOffset + translation.y
                if abs(y) >= height {
                    return
                }
                
                var frame = view.frame
                frame.origin.y = y
                view.frame = frame
                if let v = previousView {
                    frame.origin.y = y - height
                    v.frame = frame
                }
                if let v = nextView {
                    frame.origin.y = y + height
                    v.frame = frame
                }
                
                if allowAppdendViewFollowPan && appdendView != nil {
                    var tmpFrame: CGRect = appdendView!.frame
                    tmpFrame.origin.y += translation.y
                    appdendView!.frame = tmpFrame
                }
                currentItem!.setItemDeltaY(translation.y, for: view, isEndPan: false, completion: nil)
            } else if let horizontalPanResponderView = currentItem!.horizontalPanResponderView() {
                let width = horizontalPanResponderView.bounds.width
                let x: CGFloat = currentOffset + translation.x
                if abs(x) >= width {
                    return
                }
                currentItem!.setItemDeltaX(translation.x, for: horizontalPanResponderView, isBeganPan: false, isEndPan: false, beganOffsetX: beganOffsetX, completion: nil)
            }
            delegate.swipeViewController(container, gesture: gesture, direction: currentPanDirection, delta: isVertical ? translation.y : translation.x)
            gesture.setTranslation(CGPoint.zero, in: container.view)
        case .ended:
            let isVertical: Bool = .up == currentPanDirection || .down == currentPanDirection
            let offset = panOffset(isVertical: isVertical)
            if isVertical {
                if abs(offset) < validOffsetY { // 有效区域以内的滑动距离，认为无效滑动，reset回去
                    resetItemsPostion()
                    return
                } else {
                    currentItem!.setItemDeltaY(translation.y, for: currentItem!.verticalPanResponderView(), isEndPan: true, completion: nil)
                    swipeAndShow(gesture: gesture, direction: currentPanDirection) {
                        self.delegate.swipeViewController(self.container, end: gesture, direction: self.currentPanDirection)
                    }
                }
            } else {
                currentItem!.setItemDeltaX(translation.x, for: currentItem!.horizontalPanResponderView(), isBeganPan: false, isEndPan: true, beganOffsetX: beganOffsetX, completion: {
                        self.delegate.swipeViewController(self.container, end: gesture, direction: self.currentPanDirection)
                })
            }
        case .cancelled:
            resetItemsPostion()
            currentPanDirection = .unknown
        case .possible, .failed:
            currentPanDirection = .unknown
        @unknown default:
            currentPanDirection = .unknown
        }
    }
    
    private func prepareItems() {
        let itemCount = dataSource.itemCount()
        if itemCount > 1 {
            if previousView == nil {
                previousView = UIView(frame: container.view.frame)
                container.view.addSubview(previousView!)
            }
            if nextView == nil {
                nextView = UIView(frame: container.view.frame)
                container.view.addSubview(nextView!)
            }
        } else {
            previousView?.removeFromSuperview()
            previousView = nil

            nextView?.removeFromSuperview()
            nextView = nil
        }
        // 移除上一个
        currentItem?.verticalPanResponderView()?.removeFromSuperview()
        if currentItem is UIViewController {
            let vc: UIViewController = (currentItem as! UIViewController)
            vc.willMove(toParent: nil)
            if vc.shouldAutomaticallyForwardAppearanceMethods {
                vc.view.removeFromSuperview()
            } else {
                vc.beginAppearanceTransition(false, animated: true)
                vc.view.removeFromSuperview()
                vc.endAppearanceTransition()
            }
            vc.removeFromParent()
        }
        currentItem = nil
        
        // 添加新的
        currentItem = dataSource.itemViewController(container)
        if currentItem != nil {
            if currentItem is UIViewController {
                let vc = (currentItem as! UIViewController)
                container.addChild(vc)
                if vc.shouldAutomaticallyForwardAppearanceMethods {
                    container.view.addSubview(vc.view)
                } else {
                    vc.beginAppearanceTransition(true, animated: true)
                    container.view.addSubview(vc.view)
                    vc.endAppearanceTransition()
                }
                vc.didMove(toParent: container)
            } else if currentItem is UIView {
                container.view.addSubview(currentItem!.verticalPanResponderView())
            }
        }
        
        // 调整视图位置
        resetItemsPostion()
    }
        
    private func direction(whenGestureBegan gesture: UIPanGestureRecognizer) -> PanDirection {
        // 先判断速度，再判断距离
        let velocity: CGPoint = gesture.velocity(in: container.view)
        let absVelocityX = CGFloat(abs(Float(velocity.x)))
        let absVelocityY = CGFloat(abs(Float(velocity.y)))
        var direction: PanDirection = .unknown
        if absVelocityX > absVelocityY {
            direction = (velocity.x < 0) ? .left : .right
        } else if absVelocityX < absVelocityY {
            direction = (velocity.y < 0) ? .up : .down
        } else {
            // 速度相等在根据速度判断
            let translation: CGPoint = gesture.translation(in: container.view)
            let absX = CGFloat(abs(Float(translation.x)))
            let absY = CGFloat(abs(Float(translation.y)))
            if absX > absY {
                direction = (translation.x < 0) ? .left : .right
            } else if absX < absY {
                direction = (translation.y < 0) ? .up : .down
            } else {
                direction = .unknown
            }
        }
        return direction
    }
    
    // 控制一旦识别手势就不会再返回PanDirection .unknown
    private func nextDirection(previousDirection: PanDirection) -> PanDirection {
        if currentItem == nil {
            return .unknown
        }
        if previousDirection == .up  || previousDirection == .down {
            let y = currentItem!.verticalPanResponderView().frame.origin.y
            if y > verticalViewOriginalFrame.origin.y {
                return .down
            } else if y <= verticalViewOriginalFrame.origin.y {
                return .up
            }
        } else if let horizontalPanResponderView = currentItem!.horizontalPanResponderView() {
            let x = horizontalPanResponderView.frame.origin.x
            if x >= horizontalViewOriginalFrame.origin.x {
                return .right
            } else if x < horizontalViewOriginalFrame.origin.x {
                return .left
            }
        }
        return .unknown
    }
    
    private func panOffset(isVertical: Bool) -> CGFloat {
        if currentItem != nil {
            if isVertical {
                // 竖直方向
                let originY = currentItem!.verticalPanResponderView().frame.origin.y
                return originY
            } else if let horizontalPanResponderView = currentItem!.horizontalPanResponderView() {
                // 水平方向
                let originX = horizontalPanResponderView.frame.origin.x
                return originX
            }
        }
        return CGFloat.infinity
    }
    
    private func swipeAndShow(gesture: UIPanGestureRecognizer?, direction: PanDirection, completion: (() -> Void)? = nil) {
        let isForward: Bool = .down == direction

        DispatchQueue.global(qos: .default).async(execute: {
            self.dataPrefetching.itemPrefetchData(withStep: isForward ? -1 : 1)
        })
        let view: UIView! = currentItem!.verticalPanResponderView()
        var frame: CGRect = view.bounds
        if isForward {
            frame.origin.y = frame.size.height
            nextView!.frame = frame
        } else {
            frame.origin.y = -frame.size.height
            previousView!.frame = frame
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            gesture?.isEnabled = false
            var frame: CGRect = view.bounds
            var offsetStepLen: CGFloat = frame.size.height
            if isForward {
                self.previousView?.frame = frame
            } else {
                self.nextView?.frame = frame
                offsetStepLen = -offsetStepLen
            }
            frame.origin.y += offsetStepLen
            view.frame = frame
            
            if self.allowAppdendViewFollowPan {
                self.appendViewOriginalFrame.origin.y += offsetStepLen
                self.appdendView?.frame = self.appendViewOriginalFrame
            }
        }) { finished in
            gesture?.isEnabled = true
            completion?()
        }
    }
    
    private func resetItemsPostion() {
        guard let view = currentItem?.verticalPanResponderView() else {
            return
        }
        var frame: CGRect = view.bounds
        view.frame = frame
        if (previousView != nil) {
            frame.origin.y = -frame.height
            previousView?.frame = frame
        }
        if (nextView != nil) {
            frame.origin.y = frame.height
            nextView?.frame = frame
        }
        
        currentItem?.resetWhenInvalidPan()
    }
    
    private func isFastPan() -> Bool {
        let timestamp = TimeInterval(Date().timeIntervalSince1970 * 1000)
        let lastTimestamp = lastPanTimestamp
        lastPanTimestamp = timestamp
        return (timestamp - lastTimestamp <= fastSwipeThreshold) ? true : false
    }
    
    private func handleContinuouslyFastPan() {
        dataSource.fastSwipeBackground(backgroundView)
    }
}

extension SwipeScreenProxy: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pan {
            currentPanDirection = direction(whenGestureBegan: gestureRecognizer as! UIPanGestureRecognizer)
            if .unknown == currentPanDirection {
                // 工程容错，这种情况在工程实践中几乎不会出现，如果出现，让手势识别失败，重新开始
                return false
            }
        }
        var flag = true
        // 委托的优先级高，放在后面执行
        flag = dataSource.swipeViewControlelr(container, gestureRecognizerShouldBegin: gestureRecognizer, direction: currentPanDirection)
        if !flag {
            return flag
        }
        
        if let item = currentItem {
            flag = item.shouldBegan(gestureRecognizer)
            if !flag {
                return flag
            }
        }
        
        return flag
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        var flag = false
        flag = dataSource.swipeViewControlelr(container, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer, direction: currentPanDirection)
        
        return flag
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        var flag = false
        // 这个if现在没用，备用于扩展，防止使用方向其中添加新的手势
        if (otherGestureRecognizer is UIPanGestureRecognizer) {
            if (gestureRecognizer is UISwipeGestureRecognizer) || (gestureRecognizer is UILongPressGestureRecognizer) || (gestureRecognizer is UITapGestureRecognizer) {
                flag = true
            }
        }
        flag = dataSource.swipeViewControlelr(container, gestureRecognizer: gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer, direction: currentPanDirection)
        
        return flag
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var flag = true
        flag = dataSource.swipeViewControlelr(container, gestureRecognizer: gestureRecognizer, shouldReceive: touch, direction: currentPanDirection)
        if !flag {
            return flag
        }
        
        if let item = currentItem {
            flag = item.shouldReceive(touch)
            if !flag {
                return flag
            }
        }
        
        return flag
    }
}
