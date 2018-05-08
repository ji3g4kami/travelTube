//
//  FirebaseManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct FirebaseUserInfo {
    var uid: String
    var email: String
    var name: String
    var userImage: URL
}

class FirebaseManager {
    static let shared = FirebaseManager()
    var ref = Database.database().reference()
    var user: FirebaseUserInfo?
}
