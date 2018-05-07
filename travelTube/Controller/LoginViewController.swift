//
//  LoginViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    @IBAction func login(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let uid = user?.uid {
                UserManager.shared.uid = uid
            }
            if auth.currentUser != nil {
                UserManager.shared.isLoggedIn = true
                self.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }
    }
}
