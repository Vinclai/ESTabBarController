//
//  ESTabBarItemContainer.swift
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

internal class ESTabBarItemContainer: UIControl {
    
    internal init(_ target: AnyObject?, tag: Int) {
        super.init(frame: CGRect.zero)
        self.tag = tag
        self.addTarget(target, action: #selector(ESTabBar.selectAction(_:)), forControlEvents: .TouchUpInside)
        self.addTarget(target, action: #selector(ESTabBar.highlightAction(_:)), forControlEvents: .TouchDown)
        self.addTarget(target, action: #selector(ESTabBar.highlightAction(_:)), forControlEvents: .TouchDragEnter)
        self.addTarget(target, action: #selector(ESTabBar.dehighlightAction(_:)), forControlEvents: .TouchDragExit)
        self.backgroundColor = UIColor.clearColor()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        for subview in self.subviews {
            if let subview = subview as? ESTabBarItemContentView {
                subview.frame = CGRect.init(x: subview.insets.left, y: subview.insets.top, width: bounds.size.width - subview.insets.left - subview.insets.right, height: bounds.size.height - subview.insets.top - subview.insets.bottom)
                subview.updateLayout()
            }
        }
    }

    internal override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var b = super.pointInside(point, withEvent: event)
        if !b {
            for subview in self.subviews {
                if subview.pointInside(CGPoint(x: point.x - subview.frame.origin.x, y: point.y - subview.frame.origin.y), withEvent: event) {
                    b = true
                }
            }
        }
        return b
    }
}
