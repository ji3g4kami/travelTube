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

    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: "LoggedIn")
        }
        set {
            defaults.set(newValue, forKey: "LoggedIn")
        }
    }

    var userId: String {
        get {
            // swiftlint:disable force_cast
            return defaults.value(forKey: "userId") as! String
        }
        set {
            defaults.set(newValue, forKey: "userId")
        }
    }
}
