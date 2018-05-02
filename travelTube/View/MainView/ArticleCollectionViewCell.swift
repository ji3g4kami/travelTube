//
//  ArticleCollectionViewCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer

class ArticleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoPlayer: YouTubePlayerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
