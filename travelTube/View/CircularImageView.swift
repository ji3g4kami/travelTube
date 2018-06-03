//
//  CircularImageView.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

@IBDesignable
class CircularImageView: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
