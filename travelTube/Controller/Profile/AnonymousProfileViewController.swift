//
//  AnonymousProfileViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SKActivityIndicatorView

class AnonymousProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutPressed(_ sender: UIButton) {
        SKActivityIndicator.show("Loading...")
        AuthManager.shared.logout {
            // get a reference to the app delegate
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.toLoginPage()
            SKActivityIndicator.dismiss()
        }
    }

}
