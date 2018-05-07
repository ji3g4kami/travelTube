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
            if user != nil {
                if UserDefaults.standard.string(forKey: "uid") != nil && Auth.auth().currentUser != nil {
                    //User was already logged in
                }

                UserDefaults.standard.setValue(user?.uid, forKeyPath: "uid")

                self.performSegue(withIdentifier: "CurrentlyLoggedIn", sender: nil)

            }
        }
    }
}
