//
//  EditArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/31.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class EditArticleViewController: UIViewController {

    var articleInfo: Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(articleInfo)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
