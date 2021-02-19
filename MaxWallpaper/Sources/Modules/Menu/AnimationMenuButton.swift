//
//  AnimationMenuButton.swift
//  AnimationMenuButton
//
//  Created by 大鲨鱼 on 2018/7/18.
//  Copyright © 2018年 大鲨鱼. All rights reserved.


import UIKit

// MARK: helpers
func customize<Type>(_ value: Type, block: (_ object: Type) -> Void) -> Type {
    block(value)
    return value
}

// MARK: Protocol
// viewControl里面的内容
//let button = MenuAnimation(
//    frame: CGRect(x: 200, y: 200, width: 50, height: 50),
//    normalIcon:"ic_menu",
//    selectedIcon:"ic_close",
//    buttonsCount: 4,
//    duration: 4,
//    distance: 120)
//button.backgroundColor = UIColor.white
//button.layer.cornerRadius = button.frame.size.width / 2.0
//view.addSubview(button)



/// A Button object with pop ups buttons
open class AnimationMenuButton: UIButton {

    // MARK: properties

    /// Buttons count
    @IBInspectable open var buttonsCount: Int = 3
    /// Circle animation duration
    @IBInspectable open var duration: Double = 2
    /// Distance between center button and buttons
    @IBInspectable open var distance: Float = 100
    /// Delay between show buttons
    @IBInspectable open var showDelay: Double = 0
    /// Start angle of the circle
    @IBInspectable open var startAngle: Float = 0
    /// End angle of the circle
    @IBInspectable open var endAngle: Float = 360

    // Pop buttons radius, if nil use center button size
    open var subButtonsRadius: CGFloat?
    
    var isShow = false
    
    
    // Show buttons event
    open var showButtonsEvent: UIControl.Event = UIControl.Event.touchUpInside {
        didSet {
            addActions(newEvent: showButtonsEvent, oldEvent: oldValue)
        }
    }

    /// The object that acts as the delegate of the circle menu.
    @IBOutlet open weak var delegate: AnyObject? // CircleMenuDelegate?

    var buttons: [UIButton]?
    weak var platform: UIView?

    public var customNormalIconView: UIImageView?
    public var customSelectedIconView: UIImageView?

    /**
     Initializes and returns a circle menu object.

     - parameter frame:        A rectangle specifying the initial location and size of the circle menu in its superview’s coordinates.
     - parameter normalIcon:   The image to use for the specified normal state.
     - parameter selectedIcon: The image to use for the specified selected state.
     - parameter buttonsCount: The number of buttons.
     - parameter duration:     The duration, in seconds, of the animation.
     - parameter distance:     Distance between center button and sub buttons.

     - returns: A newly created circle menu.
     */
    public init(frame: CGRect,
                normalIcon: String?,
                selectedIcon: String?,
                buttonsCount: Int = 3,
                duration: Double = 2,
                distance: Float = 100) {
        super.init(frame: frame)

        if let icon = normalIcon {
            setImage(UIImage(named: icon), for: .normal)
        }

        if let icon = selectedIcon {
            setImage(UIImage(named: icon), for: .selected)
        }

        self.buttonsCount = buttonsCount
        self.duration = duration
        self.distance = distance

        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    fileprivate func commonInit() {
        addActions(newEvent: showButtonsEvent)

        customNormalIconView = addCustomImageView(state: .normal)

        customSelectedIconView = addCustomImageView(state: .selected)
        customSelectedIconView?.alpha = 0
        
        setImage(UIImage(), for: .normal)
        setImage(UIImage(), for: .selected)
    }
    
    /**
     Check is sub buttons showed
     */
    open func buttonsIsShown() -> Bool {
        guard let buttons = self.buttons else {
            return false
        }

        for button in buttons {
            if button.alpha == 0 {
                return false
            }
        }
        return true
    }

  open override func removeFromSuperview() {
    if self.platform?.superview != nil { self.platform?.removeFromSuperview() }
    super.removeFromSuperview()
  }
  
    // MARK: create


    fileprivate func addCustomImageView(state: UIControl.State) -> UIImageView? {
        guard let image = image(for: state) else {
            return nil
        }

        let iconView = customize(UIImageView(image: image)) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .center
            $0.isUserInteractionEnabled = false
        }
        addSubview(iconView)

        // added constraints
        iconView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .height, multiplier: 1, constant: bounds.size.height))

        iconView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                  attribute: .width, multiplier: 1, constant: bounds.size.width))

        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: iconView,
                                         attribute: .centerX, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: iconView,
                                         attribute: .centerY, multiplier: 1, constant: 0))

        return iconView
    }

    fileprivate func createPlatform() -> UIView {
        let platform = customize(UIView(frame: .zero)) {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        superview?.insertSubview(platform, belowSubview: self)

        // constraints
        let sizeConstraints = [NSLayoutConstraint.Attribute.width, .height].map {
            NSLayoutConstraint(item: platform,
                               attribute: $0,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: $0,
                               multiplier: 1,
                               constant: CGFloat(distance * Float(2.0)))
        }
        platform.addConstraints(sizeConstraints)

        let centerConstraints = [NSLayoutConstraint.Attribute.centerX, .centerY].map {
            NSLayoutConstraint(item: self,
                               attribute: $0,
                               relatedBy: .equal,
                               toItem: platform,
                               attribute: $0,
                               multiplier: 1,
                               constant: 0)
        }
        superview?.addConstraints(centerConstraints)

        return platform
    }

    // MARK: configure

    fileprivate func addActions(newEvent: UIControl.Event, oldEvent: UIControl.Event? = nil) {
        if let oldEvent = oldEvent { removeTarget(self, action: #selector(AnimationMenuButton.onTap), for: oldEvent) }
        addTarget(self, action: #selector(AnimationMenuButton.onTap), for: newEvent)
    }

    // MARK: actions
    
    private var isBounceAnimating: Bool = false

    @objc func onTap() {
        guard isBounceAnimating == false else { return }
        isBounceAnimating = true

//        if buttonsIsShown() == false {
//            let platform = createPlatform()
//            buttons = createButtons(platform: platform)
//            self.platform = platform
//        }
//        let isShow = !buttonsIsShown()
//        let duration = isShow ? 0.5 : 0.2
//        buttonsAnimationIsShow(isShow: isShow, duration: duration)

        tapBounceAnimation(duration: 0.5) { [weak self] _ in self?.isBounceAnimating = false }
        isShow = !isShow
        tapRotatedAnimation(0.3, isSelected: isShow)
    }


    // MARK: animations

    fileprivate func buttonsAnimationIsShow(isShow: Bool, duration: Double, hideDelay: Double = 0) {
        guard self.buttons != nil else {
            return
        }

        if isShow == false { // hide buttons and remove
            self.buttons = nil
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                if self.platform?.superview != nil { self.platform?.removeFromSuperview() }
            }
        }
    }

    fileprivate func tapBounceAnimation(duration: TimeInterval, completion: ((Bool)->())? = nil) {
        transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5,
                       options: UIView.AnimationOptions.curveLinear,
                       animations: { () -> Void in
                           self.transform = CGAffineTransform(scaleX: 1, y: 1)
                       },
                       completion: completion)
    }

    fileprivate func tapRotatedAnimation(_ duration: Float, isSelected: Bool) {

        let addAnimations: (_ view: UIImageView, _ isShow: Bool) -> Void = { view, isShow in
            var toAngle: Float = 180.0
            var fromAngle: Float = 0
            var fromScale = 1.0
            var toScale = 0.2
            var fromOpacity = 1
            var toOpacity = 0
            if isShow == true {
                toAngle = 0
                fromAngle = -180
                fromScale = 0.2
                toScale = 1.0
                fromOpacity = 0
                toOpacity = 1
            }

            let rotation = customize(CABasicAnimation(keyPath: "transform.rotation")) {
                $0.duration = TimeInterval(duration)
                $0.toValue = (toAngle.degrees)
                $0.fromValue = (fromAngle.degrees)
                $0.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            }
            let fade = customize(CABasicAnimation(keyPath: "opacity")) {
                $0.duration = TimeInterval(duration)
                $0.fromValue = fromOpacity
                $0.toValue = toOpacity
                $0.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                $0.fillMode = CAMediaTimingFillMode.forwards
                $0.isRemovedOnCompletion = false
            }
            let scale = customize(CABasicAnimation(keyPath: "transform.scale")) {
                $0.duration = TimeInterval(duration)
                $0.toValue = toScale
                $0.fromValue = fromScale
                $0.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            }

            view.layer.add(rotation, forKey: nil)
            view.layer.add(fade, forKey: nil)
            view.layer.add(scale, forKey: nil)
        }

        if let customNormalIconView = self.customNormalIconView {
            addAnimations(customNormalIconView, !isSelected)
        }
        if let customSelectedIconView = self.customSelectedIconView {
            addAnimations(customSelectedIconView, isSelected)
        }

        self.isSelected = isSelected
        alpha = isSelected ? 0.9 : 1
    }
}

// MARK: extension

internal extension Float {
    var radians: Float {
        return self * (Float(180) / Float.pi)
    }

    var degrees: Float {
        return self * Float.pi / 180.0
    }
}

internal extension UIView {

    var angleZ: Float {
        return atan2(Float(transform.b), Float(transform.a)).radians
    }
}
