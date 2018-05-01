//
//  TabBarViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

enum TabBar {
    
    case videos
    
    case profile
    
    func controller() -> UIViewController {
        
        switch self {
            
        case .videos:
            return UIStoryboard.videosStoryboard().instantiateInitialViewController()!
        
        case .profile:
            return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
        }
    }
    
    func image() -> UIImage {
        
        switch self {
            
        case .videos:
            return #imageLiteral(resourceName: "youtube")
        case .profile:
            return #imageLiteral(resourceName: "user")
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
        case .videos:
            return #imageLiteral(resourceName: "youtube").withRenderingMode(.alwaysTemplate)
        
        case .profile:
            return #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: UITabBarController {
    
    let tabs: [TabBar] = [.videos, .profile]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }
    
    private func setupTab() {
        
        tabBar.tintColor = TTColor.tabBarTintColor.color()
        
        var controllers: [UIViewController] = []
        
        for tab in tabs {
            
            let controller = tab.controller()
            
            let item = UITabBarItem(
                title: nil,
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )
            
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            
            controller.tabBarItem = item
            
            controllers.append(controller)
        }
        
        setViewControllers(controllers, animated: false)
    }
    
}
