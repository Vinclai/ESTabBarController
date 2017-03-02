//
//  ESTabBar.swift
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


/// 对原生的UITabBarItemPositioning进行扩展，通过UITabBarItemPositioning设置时，系统会自动添加insets，这使得添加背景样式的需求变得不可能实现。ESTabBarItemPositioning完全支持原有的item Position 类型，除此之外还支持完全fill模式。
///
/// - automatic: UITabBarItemPositioning.automatic
/// - fill: UITabBarItemPositioning.fill
/// - centered: UITabBarItemPositioning.centered
/// - fillExcludeSeparator: 完全fill模式，布局不覆盖tabBar顶部分割线
/// - fillIncludeSeparator: 完全fill模式，布局覆盖tabBar顶部分割线
public enum ESTabBarItemPositioning : Int {
    
    case Automatic
    
    case Fill
    
    case Centered
    
    case FillExcludeSeparator
    
    case FillIncludeSeparator
}



/// 对UITabBarDelegate进行扩展，以支持UITabBarControllerDelegate的相关方法桥接
internal protocol ESTabBarDelegate {

    /// 当前item是否支持选中
    ///
    /// - Parameters:
    ///   - tabBar: tabBar
    ///   - item: 当前item
    /// - Returns: Bool
    func tabBar(tabBar: UITabBar, shouldSelect item: UITabBarItem) -> Bool
    
    /// 当前item是否需要被劫持
    ///
    /// - Parameters:
    ///   - tabBar: tabBar
    ///   - item: 当前item
    /// - Returns: Bool
    func tabBar(tabBar: UITabBar, shouldHijack item: UITabBarItem) -> Bool
    
    /// 当前item的点击被劫持
    ///
    /// - Parameters:
    ///   - tabBar: tabBar
    ///   - item: 当前item
    /// - Returns: Void
    func tabBar(tabBar: UITabBar, didHijack item: UITabBarItem)
}



/// ESTabBar是高度自定义的UITabBar子类，通过添加UIControl的方式实现自定义tabBarItem的效果。目前支持tabBar的大部分属性的设置，例如delegate,items,selectedImge,itemPositioning,itemWidth,itemSpacing等，以后会更加细致的优化tabBar原有属性的设置效果。
public class ESTabBar: UITabBar {
    
    internal var customDelegate: ESTabBarDelegate?
    
    /// tabBar中items布局偏移量
    public var itemEdgeInsets = UIEdgeInsetsZero
    /// 是否设置为自定义布局方式，默认为空。如果为空，则通过itemPositioning属性来设置。如果不为空则忽略itemPositioning,所以当tabBar的itemCustomPositioning属性不为空时，如果想改变布局规则，请设置此属性而非itemPositioning。
    public var itemCustomPositioning: ESTabBarItemPositioning? {
        didSet {
            if let itemCustomPositioning = itemCustomPositioning {
                switch itemCustomPositioning {
                case .Fill:
                    itemPositioning = .Fill
                case .Automatic:
                    itemPositioning = .Automatic
                case .Centered:
                    itemPositioning = .Centered
                default:
                    break
                }
            }
            self.reload()
        }
    }
    /// tabBar自定义item的容器view
    internal var containers = [ESTabBarItemContainer]()
    /// 缓存当前tabBarController用来判断是否存在"More"Tab
    internal weak var tabBarController: UITabBarController?
    /// 自定义'More'按钮样式，继承自ESTabBarItemContentView
    public var moreContentView: ESTabBarItemContentView? = ESTabBarItemMoreContentView.init() {
        didSet { self.reload() }
    }
    
    public override var items: [UITabBarItem]? {
        didSet {
            self.reload()
        }
    }
    
    public var isEditing: Bool = false {
        didSet {
            if oldValue != isEditing {
                self.updateLayout()
            }
        }
    }
    
    public override func setItems(items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        self.reload()
    }
    
    public override func beginCustomizingItems(items: [UITabBarItem]) {
        ESTabBarController.printError("beginCustomizingItems(_:) is unsupported in ESTabBar.")
        super.beginCustomizingItems(items)
    }
    
    public override func endCustomizingAnimated(animated: Bool) -> Bool {
        ESTabBarController.printError("endCustomizing(_:) is unsupported in ESTabBar.")
        return super.endCustomizingAnimated(animated)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
    }
    
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var b = super.pointInside(point, withEvent: event)
        if !b {
            for container in containers {
                if container.pointInside(CGPoint(x: point.x - container.frame.origin.x, y: point.y - container.frame.origin.y), withEvent: event) {
                    b = true
                }
            }
        }
        return b

    }
}

internal extension ESTabBar /* Layout */ {
    
    internal func updateLayout() {
        guard let tabBarItems = self.items else {
            ESTabBarController.printError("empty items")
            return
        }
        
        let tabBarButtons = subviews.filter { subview -> Bool in
            if let cls = NSClassFromString("UITabBarButton") {
                return subview.isKindOfClass(cls)
            }
            return false
            } .sort { (subview1, subview2) -> Bool in
                return subview1.frame.origin.x < subview2.frame.origin.x
        }
                
        if isCustomizing() {
            for (idx, _) in tabBarItems.enumerate() {
                tabBarButtons[idx].hidden = false
                moreContentView?.hidden = true
            }
            for (_, container) in containers.enumerate(){
                container.hidden = true
            }
        } else {
            for (idx, item) in tabBarItems.enumerate() {
                if let _ = item as? ESTabBarItem {
                    tabBarButtons[idx].hidden = true
                } else {
                    tabBarButtons[idx].hidden = false
                }
                if isMoreItem(idx), let _ = moreContentView {
                    tabBarButtons[idx].hidden = true
                }
            }
            for (_, container) in containers.enumerate(){
                container.hidden = false
            }
        }
        
        var layoutBaseSystem = true
        if let itemCustomPositioning = itemCustomPositioning {
            switch itemCustomPositioning {
            case .Fill, .Automatic, .Centered:
                break
            case .FillIncludeSeparator, .FillExcludeSeparator:
                layoutBaseSystem = false
            }
        }
        
        if layoutBaseSystem {
            // System itemPositioning
            for (idx, container) in containers.enumerate(){
                container.frame = tabBarButtons[idx].frame
            }
        } else {
            // Custom itemPositioning
            var x: CGFloat = itemEdgeInsets.left
            var y: CGFloat = itemEdgeInsets.top
            switch itemCustomPositioning! {
            case .FillExcludeSeparator:
                if y <= 0.0 {
                    y += 1.0
                }
            default:
                break
            }
            let width = bounds.size.width - itemEdgeInsets.left - itemEdgeInsets.right
            let height = bounds.size.height - y - itemEdgeInsets.bottom
            let eachWidth = itemWidth == 0.0 ? width / CGFloat(containers.count) : itemWidth
            let eachSpacing = itemSpacing == 0.0 ? 0.0 : itemSpacing
            
            for container in containers {
                container.frame = CGRect.init(x: x, y: y, width: eachWidth, height: height)
                x += eachWidth
                x += eachSpacing
            }
        }
    }
}

internal extension ESTabBar /* Actions */ {
    
    internal func isMoreItem(index: Int) -> Bool {
        return ESTabBarController.isShowingMore(tabBarController) && (index == (items?.count ?? 0) - 1)
    }
    
    internal func removeAll() {
        for container in containers {
            container.removeFromSuperview()
        }
        containers.removeAll()
    }
    
    internal func reload() {
        removeAll()
        guard let tabBarItems = self.items else {
            ESTabBarController.printError("empty items")
            return
        }
        for (idx, item) in tabBarItems.enumerate() {
            let container = ESTabBarItemContainer.init(self, tag: 1000 + idx)
            self.addSubview(container)
            self.containers.append(container)
            
            if let item = item as? ESTabBarItem, let contentView = item.contentView {
                container.addSubview(contentView)
            }
            if self.isMoreItem(idx), let moreContentView = moreContentView {
                container.addSubview(moreContentView)
            }
        }
        
        self.setNeedsLayout()
    }
    
    internal func highlightAction(sender: AnyObject?) {
        guard let container = sender as? ESTabBarItemContainer else {
            return
        }
        let newIndex = max(0, container.tag - 1000)
        guard newIndex < items?.count ?? 0, let item = self.items?[newIndex] where item.enabled == true else {
            return
        }
        
        if (customDelegate?.tabBar(self, shouldSelect: item) ?? true) == false {
            return
        }
        
        if let item = item as? ESTabBarItem {
            item.contentView?.highlight(true, completion: nil)
        } else if self.isMoreItem(newIndex) {
            moreContentView?.highlight(true, completion: nil)
        }
    }
    
    internal func dehighlightAction(sender: AnyObject?) {
        guard let container = sender as? ESTabBarItemContainer else {
            return
        }
        let newIndex = max(0, container.tag - 1000)
        guard newIndex < items?.count ?? 0, let item = self.items?[newIndex] where item.enabled == true else {
            return
        }
        
        if (customDelegate?.tabBar(self, shouldSelect: item) ?? true) == false {
            return
        }
        
        if let item = item as? ESTabBarItem {
            item.contentView?.dehighlight(true, completion: nil)
        } else if self.isMoreItem(newIndex) {
            moreContentView?.dehighlight(true, completion: nil)
        }
    }
    
    internal func selectAction(sender: AnyObject?) {
        guard let container = sender as? ESTabBarItemContainer else {
            return
        }
        select(itemAtIndex: container.tag - 1000, animated: true)
    }
    
    internal func select(itemAtIndex idx: Int, animated: Bool) {
        let newIndex = max(0, idx)
        let currentIndex = (selectedItem != nil) ? (items?.indexOf(selectedItem!) ?? -1) : -1
        guard newIndex < items?.count ?? 0, let item = self.items?[newIndex] where item.enabled == true else {
            return
        }
        
        if (customDelegate?.tabBar(self, shouldSelect: item) ?? true) == false {
            return
        }
        
        if (customDelegate?.tabBar(self, shouldHijack: item) ?? false) == true {
            customDelegate?.tabBar(self, didHijack: item)
            if animated {
                if let item = item as? ESTabBarItem {
                    item.contentView?.select(animated, completion: {
                        item.contentView?.deselect(false, completion: nil)
                    })
                } else if self.isMoreItem(newIndex) {
                    moreContentView?.select(animated, completion: {
                        self.moreContentView?.deselect(animated, completion: nil)
                    })
                }
            }
            return
        }
        
        if currentIndex != newIndex {
            if currentIndex != -1 && currentIndex < items?.count ?? 0{
                if let currentItem = items?[currentIndex] as? ESTabBarItem {
                    currentItem.contentView?.deselect(animated, completion: nil)
                } else if self.isMoreItem(currentIndex) {
                    moreContentView?.deselect(animated, completion: nil)
                }
            }
            if let item = item as? ESTabBarItem {
                item.contentView?.select(animated, completion: nil)
            } else if self.isMoreItem(newIndex) {
                moreContentView?.select(animated, completion: nil)
            }
            delegate?.tabBar?(self, didSelectItem: item)
        } else if currentIndex == newIndex {
            if let item = item as? ESTabBarItem {
                item.contentView?.reselect(animated, completion: nil)
            } else if self.isMoreItem(newIndex) {
                moreContentView?.reselect(animated, completion: nil)
            }
            if let navVC = tabBarController?.selectedViewController?.navigationController {
                navVC.popToRootViewControllerAnimated(animated)
            }
        }
    }
}
