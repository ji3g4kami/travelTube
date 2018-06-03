//
//  ArticleCollectionViewCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class ArticleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var youtubeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTopToImageContraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomContraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = titleLabel.font.withSize(self.frame.height/20 + 5)
        titleLabel.sizeToFit()
        titleTopToImageContraint.constant = self.frame.height/30
        titleBottomContraint.constant = titleTopToImageContraint.constant
//        youtubeImage.layer.cornerRadius = youtubeImage.frame.height*0.1
        setupImage()
    }

    func setupImage() {
        youtubeImage.clipsToBounds = true
        youtubeImage.layer.cornerRadius = 8
        youtubeImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

}
