//
//  Extensions.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/21.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}
