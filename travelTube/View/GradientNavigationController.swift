//
//  GradientNavigationController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class GradientNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.arrangeGradientLayer()

        self.arrageBarItem(color: .white)
    }

    private func arrageBarItem(color: UIColor) {
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color]
        self.navigationBar.tintColor = color
    }

    private func arrangeGradientLayer() {

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
            width: self.navigationBar.bounds.width,
            height: self.navigationBar.bounds.height
        )

        guard let image = layer.createGradientImage() else { return }

        self.navigationBar.setBackgroundImage(image, for: .topAttached, barMetrics: .default)
    }

    private func arrangeShadowLayer() {

        self.navigationBar.layer.shadowColor = UIColor.black.cgColor

        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4 )

        self.navigationBar.layer.shadowRadius = 4.0

        self.navigationBar.layer.shadowOpacity = 0.25
    }
}
