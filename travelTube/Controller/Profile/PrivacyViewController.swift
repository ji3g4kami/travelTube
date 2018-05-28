//
//  PrivacyViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/28.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
