//
//  TabBarViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

enum TabBar {

    case feed

    case post

    case search

    case profile

    func controller() -> UIViewController {

        switch self {

        case .feed:
            return UIStoryboard.feedStoryboard().instantiateInitialViewController()!

        case .search:
            return UIStoryboard.searchStoryboard().instantiateInitialViewController()!

        case .post:
            return UIStoryboard.postStoryboard().instantiateInitialViewController()!

        case .profile:
            return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
        }
    }

    func image() -> UIImage {

        switch self {

        case .feed:
            return #imageLiteral(resourceName: "youtube")
        case .post:
            return #imageLiteral(resourceName: "news")
        case .search:
            return #imageLiteral(resourceName: "search")
        case .profile:
            return #imageLiteral(resourceName: "user")
        }
    }

    func title() -> String {
        switch self {

        case .feed:
            return "feed"
        case .search:
            return  "search"
        case .post:
            return "post"
        case .profile:
            return  "profile"
        }
    }

    func selectedImage() -> UIImage {

        switch self {

        case .feed:
            return #imageLiteral(resourceName: "youtube").withRenderingMode(.alwaysTemplate)

        case .post:
            return #imageLiteral(resourceName: "news").withRenderingMode(.alwaysTemplate)

        case .search:
            return #imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate)

        case .profile:
            return #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: UITabBarController {

    let tabs: [TabBar] = [.feed, .post, .search, .profile]

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
