//
//  FeedViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

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

    func getNewFeed() {
        FirebaseManager.shared.ref.child("articles").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
        })
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
