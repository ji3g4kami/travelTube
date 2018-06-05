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
import SDWebImage
import TagListView
import SKActivityIndicatorView

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var articleArray = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setGradientBackground()
        SKActivityIndicator.show("Loading...")
        setupTableView()
        getFeeds()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromDelete(_:)), name: NSNotification.Name(rawValue: "deleteArticle"), object: nil)
    }

    @objc func updateFromDelete(_ notification: NSNotification) {
        if let article = notification.userInfo?["article"] as? Article {
            articleArray = articleArray.filter { $0 == article }
            tableView.reloadData()
        }
    }

    func setupTableView() {
//        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "blur-lake"))
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: FeedCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: FeedCell.self))
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func getFeeds() {
        FirebaseManager.shared.ref.child("articles").queryOrdered(byChild: "updateTime").queryStarting(atValue: 0).observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let article = try FirebaseDecoder().decode(Article.self, from: value)
                self.articleArray.append(article)
                DispatchQueue.main.async {
                    self.articleArray.sort(by: { (article1, article2) -> Bool in
                        article1.updateTime > article2.updateTime
                    })
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }

    @objc func saveArticleToCoreData(_ sender: UIButton) {
        print("\nLike button\(sender.tag) pressed\n")
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if articleArray.count > 0 {
            SKActivityIndicator.dismiss()
        }
        return articleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UITableViewCell() }
        cell.videoImage.sd_setImage(with: URL(string: articleArray[indexPath.row].youtubeImage), placeholderImage: #imageLiteral(resourceName: "lantern"))
        cell.titleLabel.text = articleArray[indexPath.row].youtubeTitle
        cell.backgroundColor = UIColor.clear
        cell.tagsView.removeAllTags()
        if let tags = articleArray[indexPath.row].tag {
            cell.tagsView.addTags(tags)
        }
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(saveArticleToCoreData), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        controller.youtubeId = articleArray[indexPath.row].youtubeId
        controller.articleId = articleArray[indexPath.row].articleId
        controller.hidesBottomBarWhenPushed = true
        self.present(controller, animated: true, completion: nil)
    }
}
