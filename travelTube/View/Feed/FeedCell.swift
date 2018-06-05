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
    @IBOutlet weak var likeButton: UIButton!

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

    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "btn_like_normal") {
            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
        }
    }
}
