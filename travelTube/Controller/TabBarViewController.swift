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
            return #imageLiteral(resourceName: "post")
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
            return #imageLiteral(resourceName: "post").withRenderingMode(.alwaysTemplate)

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
            tabs = [.feed, .post, .profile]
        }
        setupTab()
        setGradient()
        setItemColor()
    }

    private func setItemColor() {
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.6941176471, green: 0.7098039216, blue: 0.7529411765, alpha: 1)
    }

    private func setGradient() {
        let layer = CAGradientLayer()

        layer.colors = [
            TTColor.lightBlue.color().cgColor,
            TTColor.darkBlue.color().cgColor
        ]

        layer.startPoint = CGPoint(x: 0.0, y: 0.5)

        layer.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.bounds = CGRect(
            x: 0,
            y: 0,
            width: self.tabBar.bounds.width,
            height: self.tabBar.bounds.height
        )

        self.tabBar.backgroundImage = layer.createGradientImage()
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
