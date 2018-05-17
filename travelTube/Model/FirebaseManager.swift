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
import CodableFirebase

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

struct Article: Codable {
    var annotations: [Annotation]
    var tag: [String]
    let uid: String
    var updateTime: Date
    let youtubeId: String
    let youtubeImage: String
    let youtubePublishDate: Date
    let youtubeTitle: String
}

struct Annotation: Codable {
    let latitude: Double
    let logitutde: Double
    let title: String
}
