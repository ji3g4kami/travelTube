//
//  AuthManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Firebase
import GoogleSignIn

public class AuthManager {

    static let shared = AuthManager()

    func login(completion: @escaping () -> Void) {
        GIDSignIn.sharedInstance().signIn()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let uid = user?.uid {
                UserManager.shared.uid = uid
            }
            if auth.currentUser != nil {
                UserManager.shared.isLoggedIn = true
                print("Logged In")
                completion()
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
