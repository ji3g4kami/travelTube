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
        balloonFlying()
    }

    @IBAction func login(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func privacyButtonPressed(_ sender: Any) {
        guard let controller = UIStoryboard.profileStoryboard().instantiateViewController(
            withIdentifier: String(describing: PrivacyViewController.self)
            ) as? PrivacyViewController else { return }
        self.present(controller, animated: true, completion: nil)
    }

    func balloonFlying() {
        let emitter = Emmiter.get(with: #imageLiteral(resourceName: "hot-air-balloon"))
        emitter.emitterPosition = CGPoint(x: view.frame.width/2, y: view.frame.height)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 2)
        view.layer.insertSublayer(emitter, at: 1)
    }
}
