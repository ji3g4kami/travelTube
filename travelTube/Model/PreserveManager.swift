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

    func getArticleIdsFromCoreData() {

        do {
            if let managedContext = appDelegate?.persistentContainer.viewContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preserved")
                let result = try managedContext.fetch(fetchRequest)
                guard let articles = result as? [NSManagedObject] else { return }
                preservedArticleId.removeAll()
                for article in articles {
                    if let articleId = article.value(forKey: "articleId") as? String {
                        self.preservedArticleId.append(articleId)
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
    let tags: [String]
    let youtubeImage: String
    let youtubeTitle: String
}

class ArticleNSManagedObject: NSManagedObject {
    @NSManaged var articleId: String
    @NSManaged var tags: [String]
    @NSManaged var youtubeImage: String
    @NSManaged var youtubeTitle: String

    var preserveArticle: PreserveArticle {
        get {
            return PreserveArticle(articleId: self.articleId, tags: self.tags, youtubeImage: self.youtubeImage, youtubeTitle: self.youtubeImage)
        }
        set {
            self.articleId = newValue.articleId
            self.tags = newValue.tags
            self.youtubeImage = newValue.youtubeImage
            self.youtubeTitle = newValue.youtubeTitle
        }
    }
}
