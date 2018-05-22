//
//  FirebaseManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
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
    lazy var ref = Database.database().reference()
    lazy var storageRef = Storage.storage().reference()
    var user: FirebaseUserInfo?

    var profileImageRef: StorageReference {
        return storageRef.child("profile")
    }

    func updateProfilePhoto(uploadImage: UIImage?) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let uid = UserManager.shared.uid
        let imageRef = profileImageRef.child("\(uid).jpg")

        guard let image = uploadImage, let data = UIImageJPEGRepresentation(image, 0.1) else { return }
        imageRef.putData(data, metadata: metadata) { (_, error) in
            if let error = error {
                print("Couldn't upload image", error.localizedDescription)
            } else {
                print("Successfully uploaded image")
                imageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let url = url {
                        print(url)
                    }
                })
            }
        }
    }
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
