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
    @IBOutlet weak var commentTextView: DesignableTextView!
    var articleId: String?
    var comment: Comment?

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.text = comment?.comment
        userImage.setRounded()
        if let userImageUrl = UserManager.shared.userImage {
            userImage.sd_setImage(with: URL(string: userImageUrl), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        guard let commentId = comment?.commentId else { return }
        guard let articleId = articleId else { return }
                FirebaseManager.shared.ref.child("comments/\(articleId)").child(commentId).updateChildValues(["comment": commentTextView.text])
        dismiss(animated: true, completion: nil)
    }
}
