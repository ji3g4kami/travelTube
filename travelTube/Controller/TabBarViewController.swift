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

    case anonymousProfile

    case profile

    func controller() -> UIViewController {

        switch self {

        case .feed:
            return UIStoryboard.feedStoryboard().instantiateInitialViewController()!

        case .anonymousProfile:
            return UIStoryboard.anonymousProfileStoryboard().instantiateInitialViewController()!

        case .post:
            return UIStoryboard.postStoryboard().instantiateInitialViewController()!

        case .profile:
            return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
        }
    }

    func image() -> UIImage {

        switch self {

        case .feed:
            return #imageLiteral(resourceName: "news")
        case .post:
            return #imageLiteral(resourceName: "youtube")
        case .anonymousProfile:
            return #imageLiteral(resourceName: "anonymous-logo")
        case .profile:
            return #imageLiteral(resourceName: "user")
        }
    }

    func title() -> String {
        switch self {

        case .feed:
            return "feed"
        case .anonymousProfile:
            return  "anonymous"
        case .post:
            return "post"
        case .profile:
            return  "profile"
        }
    }

    func selectedImage() -> UIImage {

        switch self {

        case .feed:
            return #imageLiteral(resourceName: "news").withRenderingMode(.alwaysTemplate)

        case .post:
            return #imageLiteral(resourceName: "youtube").withRenderingMode(.alwaysTemplate)

        case .anonymousProfile:
            return #imageLiteral(resourceName: "anonymous-logo").withRenderingMode(.alwaysTemplate)

        case .profile:
            return #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: UITabBarController {

    var tabs: [TabBar] = [.feed, .post, .profile, .anonymousProfile]

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserManager.shared.isAnonymous {
            tabs = [.feed, .anonymousProfile]
        } else {
            tabs = [.post, .feed, .profile]
        }
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

            item.imageInsets = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)

            controller.tabBarItem = item

            controllers.append(controller)
        }

        setViewControllers(controllers, animated: false)
    }

}
