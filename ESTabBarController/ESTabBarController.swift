//
//  ESTabBarController.swift
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


/// 是否需要自定义点击事件回调类型
public typealias ESTabBarControllerShouldHijackHandler = (UITabBarController, UIViewController, Int) -> (Bool)
/// 自定义点击事件回调类型
public typealias ESTabBarControllerDidHijackHandler = (UITabBarController, UIViewController, Int) -> (Void)

public class ESTabBarController: UITabBarController, ESTabBarDelegate {
    
    /// 打印异常
    public static func printError(description: String) {
        #if DEBUG
            print("ERROR: ESTabBarController catch an error '\(description)' \n")
        #endif
    }
    
    /// 当前tabBarController是否存在"More"tab
    public static func isShowingMore(tabBarController: UITabBarController?) -> Bool {
        return tabBarController?.moreNavigationController.parentViewController != nil
    }

    /// Ignore next selection or not.
    private var ignoreNextSelection = false

    /// Should hijack select action or not.
    public var shouldHijackHandler: ESTabBarControllerShouldHijackHandler?
    /// Hijack select action.
    public var didHijackHandler: ESTabBarControllerDidHijackHandler?
    
    /// Observer tabBarController's selectedViewController. change its selection when it will-set.
    public override var selectedViewController: UIViewController? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            guard !ignoreNextSelection else {
                ignoreNextSelection = false
                return
            }
            guard let tabBar = self.tabBar as? ESTabBar, let items = tabBar.items, let index = viewControllers?.indexOf(newValue) else {
                return
            }
            let value = (ESTabBarController.isShowingMore(self) && index > items.count - 1) ? items.count - 1 : index
            tabBar.select(itemAtIndex: value, animated: false)
        }
    }
    
    /// Observer tabBarController's selectedIndex. change its selection when it will-set.
    public override var selectedIndex: Int {
        willSet {
            guard !ignoreNextSelection else {
                ignoreNextSelection = false
                return
            }
            guard let tabBar = self.tabBar as? ESTabBar, let items = tabBar.items else {
                return
            }
            let value = (ESTabBarController.isShowingMore(self) && newValue > items.count - 1) ? items.count - 1 : newValue
            tabBar.select(itemAtIndex: value, animated: false)
        }
    }
    
    /// Customize set tabBar use KVC.
    public override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = { () -> ESTabBar in 
            let tabBar = ESTabBar()
            tabBar.delegate = self
            tabBar.customDelegate = self
            tabBar.tabBarController = self
            return tabBar
        }()
        self.setValue(tabBar, forKey: "tabBar")
    }

    // MARK: UITabBar delegate
    public override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        guard let idx = tabBar.items?.indexOf(item) else {
            return;
        }
        if idx == tabBar.items!.count - 1 && ESTabBarController.isShowingMore(self) {
            ignoreNextSelection = true
            selectedViewController = moreNavigationController
            return;
        }
        if let vc = viewControllers?[idx] {
            ignoreNextSelection = true
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelectViewController: vc)
        }
    }
    
    public override func tabBar(tabBar: UITabBar, willBeginCustomizingItems items: [UITabBarItem]) {
        if let tabBar = tabBar as? ESTabBar {
            tabBar.updateLayout()
        }
    }
    
    public override func tabBar(tabBar: UITabBar, willEndCustomizingItems items: [UITabBarItem], changed: Bool) {
        if let tabBar = tabBar as? ESTabBar {
            tabBar.updateLayout()
        }
    }
    
    // MARK: ESTabBar delegate
    internal func tabBar(tabBar: UITabBar, shouldSelect item: UITabBarItem) -> Bool {
        if let idx = tabBar.items?.indexOf(item), let vc = viewControllers?[idx] {
            return delegate?.tabBarController?(self, shouldSelectViewController: vc) ?? true
        }
        return true
    }
    
    internal func tabBar(tabBar: UITabBar, shouldHijack item: UITabBarItem) -> Bool {
        if let idx = tabBar.items?.indexOf(item), let vc = viewControllers?[idx] {
            return shouldHijackHandler?(self, vc, idx) ?? false
        }
        return false
    }
    
    internal func tabBar(tabBar: UITabBar, didHijack item: UITabBarItem) {
        if let idx = tabBar.items?.indexOf(item), let vc = viewControllers?[idx] {
            didHijackHandler?(self, vc, idx)
        }
    }
    
}
