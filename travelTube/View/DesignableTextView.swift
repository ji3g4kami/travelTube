//
//  DesignableTextView.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/23.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class DesignableTextView: UITextView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
