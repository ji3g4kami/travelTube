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

    override func viewDidLoad() {
        super.viewDidLoad()
        catgoryTableView.delegate = self
        catgoryTableView.dataSource = self
        catgoryTableView.estimatedRowHeight = 120
        catgoryTableView.tableFooterView = UIView()

        getNewFeed()
    }

    @IBAction func backToFeed(_ segue: UIStoryboardSegue) {
        let postArticleVC = segue.source as? PostArticleViewController
        postArticleVC?.navigationController?.popViewController(animated: false)
    }

    func getNewFeed() {

        FirebaseManager.shared.ref.child("articles").queryOrdered(byChild: "updateTime").queryStarting(atValue: 0).observe(.value) { (snapshot) in
            // swiftlint:disable force_cast
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                if let restDict = rest.value as? [String: Any] {
                    print(restDict)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section Title \(section)"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = catgoryTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell {
            return cell
        }
        return UITableViewCell()
    }

}
