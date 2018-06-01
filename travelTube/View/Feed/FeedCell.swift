//
//  CardCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/26.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import TagListView

class FeedCell: UITableViewCell {

    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var feedView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagsView: TagListView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = { view in
            view.backgroundColor = UIColor.clear
            return view
        }(UIView())
        setupTag()
        setupImage()
        self.selectionStyle = .none
    }

    func setupTag() {
        tagsView.textFont = UIFont.systemFont(ofSize: 18)
        tagsView.alignment = .left
    }

    func setupImage() {
        videoImage.clipsToBounds = true
        videoImage.layer.cornerRadius = feedView.cornerRadius
        videoImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        let color = feedView.backgroundColor
//        super.setSelected(selected, animated: animated)
//
//        if selected {
//            feedView.backgroundColor = color
//        }
//    }
//
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        let color = feedView.backgroundColor
//        super.setHighlighted(highlighted, animated: animated)
//
//        if highlighted {
//            feedView.backgroundColor = color
//        }
//    }
}
