//
//  PreserveManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/5.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import CoreData

class PreserveManager {
    static let shared = PreserveManager()

    var preservedArticleId = [String]()
    var preservedArticle = [PreserveArticle]()

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
}

struct PreserveArticle {
    let articleId: String
    let youtubeId: String
    let tags: [String]
    let youtubeImage: String
    let youtubeTitle: String
}
