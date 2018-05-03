//
//  SearchYoutubeResultCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class SearchYoutubeResultCell: UITableViewCell {

    @IBOutlet weak var videoCoverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
