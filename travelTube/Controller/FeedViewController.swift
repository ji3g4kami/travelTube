//
//  FeedViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import SKActivityIndicatorView

class FeedViewController: UIViewController {

    var articlesOfTags = [ArticlesOfTag]()
    @IBOutlet weak var catgoryTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        requestTagsAndThenArticle()
        SKActivityIndicator.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    func requestTagsAndThenArticle() {
        self.articlesOfTags.removeAll()
        getTagsArray { (tagName, articleIds) in
            print("=========\(tagName)========")
            let dispatchGroup = DispatchGroup()
            for articleId in articleIds {
                dispatchGroup.enter()
                self.requestArticle(of: articleId, in: dispatchGroup)
            }
            dispatchGroup.notify(queue: .main) {
                print("All Complete")
            }
        }

    }

    func requestArticle(of articleId: String, in myGroup: DispatchGroup) {
        FirebaseManager.shared.ref.child("articles").child(articleId).observe(.value) { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let article = try FirebaseDecoder().decode(Article.self, from: value)
                print(article)
                myGroup.leave()
            } catch {
                print(error)
            }
        }
    }

    @IBAction func backToFeed(_ segue: UIStoryboardSegue) {
        let postArticleVC = segue.source as? PostArticleViewController
        postArticleVC?.navigationController?.popViewController(animated: false)
    }

    func setupTableView() {
        catgoryTableView.delegate = self
        catgoryTableView.dataSource = self
        catgoryTableView.estimatedRowHeight = 120
    }

    func getTagsArray(completion: @escaping (String, [String]) -> Void) {
        FirebaseManager.shared.ref.child("tags").observe(.value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for child in children {
                if let value = child.value as? [String] {
                    completion(child.key, value)
                }
            }
        }
    }
}
extension FeedViewController: UITableViewDelegate, UITableViewDataSource, CategoryCellDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50.0
        }
        return 30.0
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        if section == 0 {
            header.textLabel?.font = UIFont(name: "Futura", size: 40)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return articlesOfTags[section].tag
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return articlesOfTags.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = catgoryTableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryCell {
            cell.articlesOfTag = articlesOfTags[indexPath.section]
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        }
        return 120
    }

    func colCategorySelected(youtubeId: String) {
        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        controller.youtubeId = youtubeId
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

}

struct ArticlesOfTag {
    var tag: String
    var articles: [Article]
}
