//
//  CardView.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/26.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5

    @IBInspectable var shadowOffSetWidth: CGFloat = 0

    @IBInspectable var shadowOffSetHeight: CGFloat = 5

    @IBInspectable var shadowOpacity: CGFloat = 0.5

    @IBInspectable public var shadowBlur: CGFloat = 14 {
        didSet {
            self.layer.shadowRadius = shadowBlur
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.black

    override func layoutSubviews() {

        layer.cornerRadius = cornerRadius

        layer.shadowColor = shadowColor.cgColor

        layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)

        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.shadowPath = shadowPath.cgPath

        layer.shadowOpacity = Float(shadowOpacity)
    }
}
