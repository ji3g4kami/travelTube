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
        setupTableView()
        getFeeds()
        SKActivityIndicator.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    func setupTableView() {
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
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UITableViewCell() }
        cell.videoImage.sd_setImage(with: URL(string: articleArray[indexPath.row].youtubeImage), placeholderImage: #imageLiteral(resourceName: "lantern"))
        cell.titleLabel.text = articleArray[indexPath.row].youtubeTitle
        cell.tagsView.removeAllTags()
        cell.tagsView.addTags(articleArray[indexPath.row].tag)
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
        controller.hidesBottomBarWhenPushed = true
        self.present(controller, animated: true, completion: nil)
    }
}
