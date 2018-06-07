//
//  TagCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var tagButton: DesignableButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func buttonPressed(_ sender: DesignableButton) {
        if sender.backgroundColor == .white {
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = TTColor.gradientMiddleblue.color()
        } else {
            sender.setTitleColor(TTColor.gradientMiddleblue.color(), for: .normal)
            sender.backgroundColor = .white
        }
    }
}
