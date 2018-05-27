//
//  LoginViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import GoogleSignIn
import SKActivityIndicatorView

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    @IBAction func login(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
}
