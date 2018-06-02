//
//  GradientView.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            TTColor.lightBlue.color().cgColor,
            TTColor.darkBlue.color().cgColor,
            TTColor.pink.color().cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
