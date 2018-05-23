//
//  CommentViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/23.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage

class CommentViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.setRounded()
        if let userImageUrl = UserManager.shared.userImage {
            userImage.sd_setImage(with: URL(string: userImageUrl), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
