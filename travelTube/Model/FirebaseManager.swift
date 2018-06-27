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

    func getArticleInfo(of articleId: String, completion: @escaping (Article?, Error?) -> Void) {
        ref.child("articles").child(articleId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let articleInfo = try FirebaseDecoder().decode(Article.self, from: value)
                completion(articleInfo, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        })
    }

    func getAllFeeds(completion: @escaping ([Article]) -> Void) {
        var articleArray = [Article]()
        ref.child("articles").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value, let valueDict = value as? [String: Any] else { return }
            valueDict.forEach({ (_, dictValue) in
                do {
                    let article = try FirebaseDecoder().decode(Article.self, from: dictValue)
                    articleArray.append(article)
                } catch {
                    print(error)
                }
            })
            CoreDataManager.shared.blackList.forEach({ (blackListUser) in
                articleArray = articleArray.filter { $0.uid != blackListUser.uid }
            })
            CoreDataManager.shared.blackArticle.forEach({ articleId in
                articleArray = articleArray.filter { $0.articleId != articleId }
            })
            completion(articleArray)
        }
    }

    func getFeeds(with tags: [String], completion: @escaping ([Article]) -> Void) {
        if tags.count < 1 {
            self.getAllFeeds(completion: { (articles) in
                completion(articles)
            })
        } else {
            var selectedArticleIds = [String]()
            let dispatchGroup = DispatchGroup()
            for tag in tags {
                dispatchGroup.enter()
                ref.child("tags").queryOrdered(byChild: "tag").queryEqual(toValue: tag).observeSingleEvent(of: .value) { (snapshot) in
                    if let articleTag = snapshot.value as? [String: Any] {
                        for (_, value) in articleTag {
                            guard let valueDict = value as? [String: String], let articleId = valueDict["articleId"] else { return }
                            selectedArticleIds.append(articleId)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .global()) { [weak self] in
                selectedArticleIds = Array(Set(selectedArticleIds))
                self?.getAllFeeds(completion: { (articles) in
                    let articleArray = articles.filter { selectedArticleIds.contains($0.articleId) }
                    completion(articleArray)
                })
            }
        }
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
