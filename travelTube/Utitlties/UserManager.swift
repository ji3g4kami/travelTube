//
//  UserManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation

public class UserManager {

    // Add a singleton property shared with Singleton pattern for UserManager
    static let shared = UserManager()

    let defaults = UserDefaults.standard

    enum UserLogInStatus: String {
        case gmail
        case anonymous
        case out
    }

    var isLoggedIn: Bool {
        get {
            guard let isLoggedIn = defaults.value(forKey: "LoggedIn") as? Bool else { return false }
            return isLoggedIn
        }
        set {
            defaults.set(newValue, forKey: "LoggedIn")
        }
    }

//    var isAnonymous: Bool {
//        get {
//            guard let isAnonymous = defaults.value(forKey: "isAnonymous") as? Bool else { return false }
//            return isAnonymous
//        }
//        set {
//            defaults.set(newValue, forKey: "isAnonymous")
//        }
//    }

    var uid: String? {
        get {
            guard let uid = defaults.value(forKey: "uid") as? String else { return nil }
            return uid
        }
        set {
            defaults.set(newValue, forKey: "uid")
        }
    }

    var userName: String? {
        get {
            guard let userName = defaults.value(forKey: "userName") as? String else { return nil }
            return userName
        }
        set {
            defaults.set(newValue, forKey: "userName")
        }
    }

    var userImage: String? {
        get {
            return defaults.value(forKey: "userImage") as? String
        }
        set {
            defaults.set(newValue, forKey: "userImage")
        }
    }
}
