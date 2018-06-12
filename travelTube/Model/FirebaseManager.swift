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

class FirebaseManager {
    static let shared = FirebaseManager()
    lazy var ref = Database.database().reference()
    lazy var storageRef = Storage.storage().reference()

    var profileImageRef: StorageReference {
        return storageRef.child("profile")
    }

    func updateProfilePhoto(uploadImage: UIImage?) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        guard let uid = UserManager.shared.uid else { return }
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
                    // store imageUrl to users in firebase
                    if let url = url?.absoluteString {
                        self.ref.child("users").child(uid).updateChildValues(["image": url ])
                        UserManager.shared.userImage = url
                    }
                })
            }
        }
    }
}

struct Article: Codable {
    var annotations: [Annotation]
    var tag: [String]?
    let uid: String
    let articleId: String
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
