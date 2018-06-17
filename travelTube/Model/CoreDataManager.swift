//
//  CoreDataManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/5.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    var preservedArticleId = [String]()
    var preservedArticle = [PreserveArticle]()
    var blackList = [BlackListUser]()
    var blackArticle = [String]()

    func getArticlesFromCoreData() {
        do {
            if let managedContext = appDelegate?.persistentContainer.viewContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preserved")
                let result = try managedContext.fetch(fetchRequest)
                guard let articles = result as? [NSManagedObject] else { return }
                preservedArticleId.removeAll()
                preservedArticle.removeAll()
                for article in articles {
                    if let articleId = article.value(forKey: "articleId") as? String {
                        self.preservedArticleId.append(articleId)
                    }
                    if let articleId = article.value(forKey: "articleId") as? String, let youtubeId = article.value(forKey: "youtubeId") as? String, let tags = article.value(forKey: "tags") as? [String], let youtubeImage = article.value(forKey: "youtubeImage") as? String, let youtubeTitle = article.value(forKey: "youtubeTitle") as? String {
                        self.preservedArticle.append(PreserveArticle(articleId: articleId, youtubeId: youtubeId, tags: tags, youtubeImage: youtubeImage, youtubeTitle: youtubeTitle))
                    }
                }
            }

        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
    }

    func addToBlackList(uid: String, userName: String, userImage: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let blackList = BlackList(context: managedContext)
        blackList.uid = uid
        blackList.userName = userName
        blackList.userImage = userImage
        do {
            try managedContext.save()
            print("\nSuccessfully saved data\n")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
        } catch {
            debugPrint("\nCould not save: \(error.localizedDescription)\n")
        }
    }

    func removeFromBlackList(uid: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BlackList")
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [BlackList] else { return }
            for record in result {
                if record.uid == uid {
                    managedContext.delete(record)
                    print("Deleted: \(String(describing: record.userName))")
                    CoreDataManager.shared.getBlackList()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
                }
            }
        } catch {
            debugPrint("Could not delete: \(error.localizedDescription)")
        }
        do {
            try managedContext.save()
            print("\nSuccessfully deleted data\n")
        } catch {
            debugPrint("\nCould not delete: \(error.localizedDescription)\n")
        }
    }

    func getBlackList() {
        do {
            if let managedContext = appDelegate?.persistentContainer.viewContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BlackList")
                let result = try managedContext.fetch(fetchRequest)
                guard let users = result as? [NSManagedObject] else { return }
                blackList.removeAll()
                for user in users {
                    if let uid = user.value(forKey: "uid") as? String, let userName = user.value(forKey: "userName") as? String, let userImage = user.value(forKey: "userImage") as? String {
                        self.blackList.append(BlackListUser(uid: uid, userName: userName, userImage: userImage))
                    }
                }
            }
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
    }

    func addToBlackArticle(articleId: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let blackArticle = BlackArticle(context: managedContext)
        blackArticle.articleId = articleId
        do {
            try managedContext.save()
            print("\nSuccessfully saved data\n")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
        } catch {
            debugPrint("\nCould not save: \(error.localizedDescription)\n")
        }
    }

    func getBlackArticle() {
        do {
            if let managedContext = appDelegate?.persistentContainer.viewContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BlackArticle")
                let result = try managedContext.fetch(fetchRequest)
                guard let articles = result as? [NSManagedObject] else { return }
                blackArticle.removeAll()
                for article in articles {
                    if let articleId = article.value(forKey: "articleId") as? String {
                        self.blackArticle.append(articleId)
                    }
                }
            }
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
    }
}
