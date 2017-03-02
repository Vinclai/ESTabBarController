//
//  ESTabBarItemBadgeView.swift
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

/*
 * ESTabBarItemBadgeView
 * 这个类定义了item中使用的badge视图样式，默认为ESTabBarItemBadgeView类对象。
 * 你可以设置ESTabBarItemContentView的badgeView属性为自定义的ESTabBarItemBadgeView子类，这样就可以轻松实现 自定义通知样式了。
 */
public class ESTabBarItemBadgeView: UIView {
    
    /// 默认颜色
    public static var defaultBadgeColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    
    /// Badge color
    public var badgeColor: UIColor? = defaultBadgeColor {
        didSet {
            imageView.backgroundColor = badgeColor
        }
    }
    
    /// Badge size
    public var badgeSize: CGSize = CGSizeMake(18, 18) {
        didSet {
            self.sizeThatFits(self.bounds.size)
        }
    }
    
    public var textWidthIncrease: CGFloat = 10 {
        didSet {
            self.sizeThatFits(self.bounds.size)
        }
    }
    
    /// Badge value, supprot nil, "", "1", "someText". Hidden when nil. Show Little dot style when "".
    public var badgeValue: String? {
        didSet {
            badgeLabel.text = badgeValue
        }
    }
    
    /// Image view
    public var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    
    /// 显示badgeValue的Label
    public var badgeLabel: UILabel = {
        let badgeLabel = UILabel.init(frame: CGRect.zero)
        badgeLabel.backgroundColor = UIColor.clearColor()
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.font = UIFont.systemFontOfSize(13)
        badgeLabel.textAlignment = .Center
        return badgeLabel
    }()
    
    /// Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(badgeLabel)
        self.imageView.backgroundColor = badgeColor
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     *  通过layoutSubviews()布局子视图，你可以通过重写此方法实现自定义布局。
     **/
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let badgeValue = badgeValue else {
            imageView.hidden = true
            badgeLabel.hidden = true
            return
        }
        
        imageView.hidden = false
        badgeLabel.hidden = false
        
        if badgeValue == "" {
            imageView.frame = CGRect.init(origin: CGPoint.init(x: (bounds.size.width - 8.0) / 2.0, y: (bounds.size.height - 8.0) / 2.0), size: CGSize.init(width: 8.0, height: 8.0))
        } else {
            imageView.frame = bounds
        }
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2.0
        badgeLabel.sizeToFit()
        badgeLabel.center = imageView.center
    }
    
    /*
     *  通过此方法计算badge视图需要占用父视图的frame大小，通过重写此方法可以自定义badge视图的大小。
     *  如果你需要自定义badge视图在Content中的位置，可以设置Content的badgeOffset属性。
     */
    public override func sizeThatFits(size: CGSize) -> CGSize {
        guard let _ = badgeValue else {
            return badgeSize
        }
        let textSize = badgeLabel.sizeThatFits(CGSize.init(width: CGFloat.max, height: CGFloat.max))
        return CGSize.init(width: max(badgeSize.width, textSize.width + textWidthIncrease), height: badgeSize.height)
    }
    
}
