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

    @IBAction func readOnlyLogin(_ sender: UIButton) {
        // Activity Indicator
        SKActivityIndicator.show("Loading...")
        UIApplication.shared.beginIgnoringInteractionEvents()
        AuthManager.shared.signInAnonymously(from: self) {
            self.performSegue(withIdentifier: "toMain", sender: nil)
            SKActivityIndicator.dismiss()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    @IBAction func privacyButtonPressed(_ sender: Any) {
        guard let controller = UIStoryboard.profileStoryboard().instantiateViewController(
            withIdentifier: String(describing: PrivacyViewController.self)
            ) as? PrivacyViewController else { return }
        self.present(controller, animated: true, completion: nil)
    }
}
