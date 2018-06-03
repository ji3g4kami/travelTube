//
//  CircularGradientView.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

@IBDesignable
class CircularGradientView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            TTColor.lightBlue.color().cgColor,
            TTColor.darkBlue.color().cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
