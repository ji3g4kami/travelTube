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
    
    case post
    
    case profile
    
    func controller() -> UIViewController {
        
        switch self {
            
        case .videos:
            return UIStoryboard.videosStoryboard().instantiateInitialViewController()!
        
        case .profile:
            return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
            
        case .post:
            return UIStoryboard.postStoryboard().instantiateInitialViewController()!
        }
    }
    
    func image() -> UIImage {
        
        switch self {
            
        case .videos:
            return #imageLiteral(resourceName: "youtube")
        case .profile:
            return #imageLiteral(resourceName: "user")
        case .post:
            return #imageLiteral(resourceName: "news")
        }
    }
    
    func title() -> String {
        switch self {
            
        case .videos:
            return "videos"
        case .profile:
            return  "profile"
        case .post:
            return "post"
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
        case .videos:
            return #imageLiteral(resourceName: "youtube").withRenderingMode(.alwaysTemplate)
        
        case .profile:
            return #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
            
        case .post:
            return #imageLiteral(resourceName: "news").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: UITabBarController {
    
    let tabs: [TabBar] = [.videos, .post, .profile]
    
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
                title: tab.title(),
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )
            
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -6, right: 0)
            
            controller.tabBarItem = item
            
            controllers.append(controller)
        }
        
        setViewControllers(controllers, animated: false)
    }
    
}
