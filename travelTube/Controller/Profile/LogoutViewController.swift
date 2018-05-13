//
//  LogoutViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseInvites
import GoogleSignIn

class LogoutViewController: UIViewController, InviteDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func logoutPressed(_ sender: UIButton) {
        AuthManager.shared.logout {
            // get a reference to the app delegate
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.toLoginPage()
        }
    }

    @IBAction func inviteTapped(_ sender: AnyObject) {
        if let invite = Invites.inviteDialog() {
            invite.setInviteDelegate(self)

            // NOTE: You must have the App Store ID set in your developer console project
            // in order for invitations to successfully be sent.

            // A message hint for the dialog. Note this manifests differently depending on the
            // received invitation type. For example, in an email invite this appears as the subject.
            invite.setMessage("Try this out!")
            // Title for the dialog, this is what the user sees before sending the invites.
            invite.setTitle("Invites Example")
            invite.setDeepLink("https://rfk7c.app.goo.gl")
            invite.setCallToActionText("Install!")
            invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
            invite.open()
        }
    }
}
