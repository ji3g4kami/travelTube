//
//  LoginViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    @IBAction func login(_ sender: UIButton) {
        AuthManager.shared.login {
            self.performSegue(withIdentifier: "toMain", sender: nil)
        }
    }

    @IBAction func readOnlyLogin(_ sender: UIButton) {
        AuthManager.shared.signInAnonymously(from: self) {
            self.performSegue(withIdentifier: "toMain", sender: nil)
        }
    }
}
