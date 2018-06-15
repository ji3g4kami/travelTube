//
//  CommentCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/17.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

protocol CommentCellDelegate: class {
    func commentCellDidTapProfile(_ sender: CommentCell)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!

    weak var delegate: CommentCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func profileTapped(_ sender: UIButton) {
        delegate?.commentCellDidTapProfile(self)
    }
}
