//
//  ESTabBarContentView.swift
//
//  Created by Vincent Li on 2017/2/8.
//  Copyright (c) 2013-2016 ESTabBarController (https://github.com/eggswift/ESTabBarController)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public class ESTabBarItemContentView: UIView {
    
    // MARK: - PROPERTY SETTING
    
    /// 设置contentView的偏移
    public var insets = UIEdgeInsetsZero
    
    /// 是否被选中
    public var selected = false
    
    /// 是否处于高亮状态
    public var highlighted = false
    
    /// 是否支持高亮
    public var highlightEnabled = true
    
    /// 文字颜色
    public var textColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet {
            if !selected { titleLabel.textColor = textColor }
        }
    }
    
    /// 高亮时文字颜色
    public var highlightTextColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected { titleLabel.textColor = highlightIconColor }
        }
    }
    
    /// icon颜色
    public var iconColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet {
            if !selected { imageView.tintColor = iconColor }
        }
    }
    
    /// 高亮时icon颜色
    public var highlightIconColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected { imageView.tintColor = highlightIconColor }
        }
    }
    
    /// 背景颜色
    public var backdropColor = UIColor.clearColor() {
        didSet {
            if !selected { backgroundColor = backdropColor }
        }
    }
    
    /// 高亮时背景颜色
    public var highlightBackdropColor = UIColor.clearColor() {
        didSet {
            if selected { backgroundColor = highlightBackdropColor }
        }
    }
    
    public var title: String? {
        didSet {
            self.titleLabel.text = title
            self.updateLayout()
        }
    }
    
    /// Icon imageView renderingMode, default is .alwaysTemplate like UITabBarItem
    public var renderingMode: UIImageRenderingMode = .AlwaysTemplate {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// ImageView bottom offset
    public var imageViewBottomOffset: CGFloat = 6 {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// TitleLabel bottom offset
    public var titleLabelBottomOffset: CGFloat = 1 {
        didSet {
            self.updateDisplay()
        }
    }
    
    
    /// Icon imageView's image
    public var image: UIImage? {
        didSet {
            if !selected { self.updateDisplay() }
        }
    }
    
    public var selectedImage: UIImage? {
        didSet {
            if selected { self.updateDisplay() }
        }
    }
    
    public var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    
    public var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.zero)
        titleLabel.backgroundColor = .clearColor()
        titleLabel.textColor = .clearColor()
        titleLabel.font = UIFont.systemFontOfSize(10)
        titleLabel.textAlignment = .Center
        return titleLabel
    }()
    
    
    /// 小红点相关属性
    public var badgeValue: String? {
        didSet {
            if let _ = badgeValue {
                self.badgeView.badgeValue = badgeValue
                self.addSubview(badgeView)
                self.updateLayout()
            } else {
                // Remove when nil.
                self.badgeView.removeFromSuperview()
            }
            badgeChanged(true, completion: nil)
        }
    }
    public var badgeColor: UIColor? {
        didSet {
            if let _ = badgeColor {
                self.badgeView.badgeColor = badgeColor
            } else {
                self.badgeView.badgeColor = ESTabBarItemBadgeView.defaultBadgeColor
            }
        }
    }
    public var badgeView: ESTabBarItemBadgeView = ESTabBarItemBadgeView() {
        willSet {
            if let _ = badgeView.superview {
                badgeView.removeFromSuperview()
            }
        }
        didSet {
            if let _ = badgeView.superview {
                self.updateLayout()
            }
        }
    }
    public var badgeOffset: UIOffset = UIOffset.init(horizontal: 6.0, vertical: -22.0) {
        didSet {
            if badgeOffset != oldValue {
                self.updateLayout()
            }
        }
    }
    
    // MARK: -
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = false
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        titleLabel.textColor = textColor
        imageView.tintColor = iconColor
        backgroundColor = backdropColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateDisplay() {
        imageView.image = (selected ? (selectedImage ?? image) : image)?.imageWithRenderingMode(renderingMode)
        imageView.tintColor = selected ? highlightIconColor : iconColor
        titleLabel.textColor = selected ? highlightTextColor : textColor
        backgroundColor = selected ? highlightBackdropColor : backdropColor
    }
    
    public func updateLayout() {
        let w = self.bounds.size.width
        let h = self.bounds.size.height
        imageView.hidden = (imageView.image == nil)
        titleLabel.hidden = (titleLabel.text == nil)
        
        if !imageView.hidden && !titleLabel.hidden {
            titleLabel.sizeToFit()
            imageView.sizeToFit()
            titleLabel.frame = CGRect.init(x: (w - titleLabel.bounds.size.width) / 2.0,
                                           y: h - titleLabel.bounds.size.height - titleLabelBottomOffset,
                                           width: titleLabel.bounds.size.width,
                                           height: titleLabel.bounds.size.height)
            imageView.frame = CGRect.init(x: (w - imageView.bounds.size.width) / 2.0,
                                          y: (h - imageView.bounds.size.height) / 2.0 - imageViewBottomOffset,
                                          width: imageView.bounds.size.width,
                                          height: imageView.bounds.size.height)
        } else if !imageView.hidden {
            imageView.sizeToFit()
            imageView.center = CGPoint.init(x: w / 2.0, y: h / 2.0)
        } else if !titleLabel.hidden {
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint.init(x: w / 2.0, y: h / 2.0)
        }
        
        if let _ = badgeView.superview {
            let size = badgeView.sizeThatFits(self.frame.size)
            badgeView.frame = CGRect.init(origin: CGPoint.init(x: w / 2.0 + badgeOffset.horizontal, y: h / 2.0 + badgeOffset.vertical), size: size)
        }
    }
    
    // MARK: - INTERNAL METHODS
    internal final func select(animated: Bool, completion: (() -> ())?) {
        selected = true
        if highlightEnabled && highlighted {
            highlighted = false
            dehighlightAnimation(animated, completion: { [weak self] in
                self?.updateDisplay()
                self?.selectAnimation(animated, completion: completion)
                })
        } else {
            updateDisplay()
            selectAnimation(animated, completion: completion)
        }
    }
    
    internal final func deselect(animated: Bool, completion: (() -> ())?) {
        selected = false
        updateDisplay()
        self.deselectAnimation(animated, completion: completion)
    }
    
    internal final func reselect(animated: Bool, completion: (() -> ())?) {
        if selected == false {
            select(animated, completion: completion)
        } else {
            if highlightEnabled && highlighted {
                highlighted = false
                dehighlightAnimation(animated, completion: { [weak self] in
                    self?.reselectAnimation(animated, completion: completion)
                    })
            } else {
                reselectAnimation(animated, completion: completion)
            }
        }
    }
    
    internal final func highlight(animated: Bool, completion: (() -> ())?) {
        if !highlightEnabled {
            return
        }
        if highlighted == true {
            return
        }
        highlighted = true
        self.highlightAnimation(animated, completion: completion)
    }
    
    internal final func dehighlight(animated: Bool, completion: (() -> ())?) {
        if !highlightEnabled {
            return
        }
        if !highlighted {
            return
        }
        highlighted = false
        self.dehighlightAnimation(animated, completion: completion)
    }
    
    internal func badgeChanged(animated: Bool, completion: (() -> ())?) {
        self.badgeChangedAnimation(animated, completion: completion)
    }
    
    // MARK: - ANIMATION METHODS
    public func selectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
}
