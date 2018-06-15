//
//  BlackListViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage

class BlackListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: BlackListCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: BlackListCell.self))
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension BlackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlackListCell.self), for: indexPath) as? BlackListCell else { return UITableViewCell() }
        cell.userImage.sd_setImage(with: URL(string: "https://image.flaticon.com/icons/svg/17/17004.svg"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
