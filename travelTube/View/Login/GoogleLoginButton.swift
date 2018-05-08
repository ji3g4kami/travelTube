//
//  GoogleLoginButton.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class GoogleLoginButton: UIButton {
    override func awakeFromNib() {
        self.setupView()
    }

    func setupView() {
        self.layer.cornerRadius = 5.0
    }
}
