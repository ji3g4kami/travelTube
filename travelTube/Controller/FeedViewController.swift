//
//  FeedViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var catgoryTableView: UITableView!
    var tagsArray = [[String: [String]]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        catgoryTableView.delegate = self
        catgoryTableView.dataSource = self
        catgoryTableView.estimatedRowHeight = 120

        getTagsArray()
    }

    @IBAction func backToFeed(_ segue: UIStoryboardSegue) {
        let postArticleVC = segue.source as? PostArticleViewController
        postArticleVC?.navigationController?.popViewController(animated: false)
    }

    func getTagsArray() {
        FirebaseManager.shared.ref.child("tags").observe(.value) { (snapshot) in
            self.tagsArray.removeAll()
            // swiftlint:disable force_cast
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? [String] {
                    let tagDict = [child.key: value]
                    self.tagsArray.append(tagDict)
                }
            }
            DispatchQueue.main.async {
                self.catgoryTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50.0
        }
        return 30.0
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if section == 0 {
            header.textLabel?.font = UIFont(name: "Futura", size: 40)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tagName = Array(tagsArray[section].keys)
        return tagName[0]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tagsArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = catgoryTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell {
            let articleIdArray = Array(tagsArray[indexPath.section].values)[0]
            cell.articleIdArray = articleIdArray
            cell.requstArticleData()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Have AricleIds from FeedVC"), object: nil)
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

}
