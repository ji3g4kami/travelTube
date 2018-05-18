//
//  GoogleLoginButton.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    func setupView() {
        self.layer.cornerRadius = 5.0
    }
}
