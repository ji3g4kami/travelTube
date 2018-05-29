//
//  AuthManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Firebase
import FirebaseDatabase
import GoogleSignIn

public class AuthManager: NSObject {

    static let shared = AuthManager()

    private override init() {}

    func signInAnonymously(from viewController: UIViewController, completion: @escaping () -> Void) {
        Auth.auth().signInAnonymously { (user, error) in
            if let err = error {
                let alert = UIAlertController(title: "Sign In Error", message: err.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                viewController.present(alert, animated: true, completion: nil)
            }
            if let user = user {
                if user.isAnonymous {
                    UserManager.shared.isLoggedIn = true
                    UserManager.shared.isAnonymous = true
                    UserManager.shared.uid = user.uid
                    UserManager.shared.userName = "Anonymous"
                    UserManager.shared.userImage = "https://image.flaticon.com/icons/svg/17/17004.svg"
                    print("Anonymous Logged In")
                    completion()
                }
            }
        }
    }

    func logout(completion: @escaping () -> Void) {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserManager.shared.isLoggedIn = false
            print("Logged Out")
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
