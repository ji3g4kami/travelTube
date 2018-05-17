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
import SKActivityIndicatorView

public class AuthManager {

    static let shared = AuthManager()

    func login(completion: @escaping () -> Void) {
        GIDSignIn.sharedInstance().signIn()
        SKActivityIndicator.show("Loading...")
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let uid = user?.uid, let userEmail = user?.email, let userName = user?.displayName {
                UserManager.shared.uid = uid
                UserManager.shared.userName = userName
                FirebaseManager.shared.ref.child("users").child(UserManager.shared.uid).setValue(["userName": userName, "userEmail": userEmail])
            }
            if auth.currentUser != nil {
                UserManager.shared.isLoggedIn = "gmail"
                print("Logged In with Gmail")
                completion()
            }
            SKActivityIndicator.dismiss()
        }
    }

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
                    UserManager.shared.isLoggedIn = "anonymous"
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
            UserManager.shared.isLoggedIn = "out"
            print("Logged Out")
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
