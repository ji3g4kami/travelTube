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

    func logout(completion: @escaping () -> Void) {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserManager.shared.isLoggedIn = false
            UserManager.shared.uid = nil
            UserManager.shared.userImage = nil
            UserManager.shared.userName = nil
            print("Logged Out")
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
