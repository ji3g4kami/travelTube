//
//  BlackListCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

protocol BlackListCellDelegate: class {
    func tableViewCellDidTapTrash(_ sender: BlackListCell)
}

class BlackListCell: UITableViewCell {

    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    weak var delegate: BlackListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deletePressed(_ sender: Any) {
        delegate?.tableViewCellDidTapTrash(self)
    }
}
