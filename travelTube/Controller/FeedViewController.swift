//
//  FeedViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SKActivityIndicatorView

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        SKActivityIndicator.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: FeedCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: FeedCell.self))
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UITableViewCell() }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height*2/3
    }
}
