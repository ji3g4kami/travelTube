//
//  FeedViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SKActivityIndicatorView

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        SKActivityIndicator.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
