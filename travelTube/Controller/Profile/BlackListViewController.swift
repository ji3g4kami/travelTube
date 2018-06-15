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
        setupNotificationCenter()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: BlackListCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: BlackListCell.self))
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromCoreData(_:)), name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
    }

    @objc func updateFromCoreData(_ notification: NSNotification) {
        self.tableView.reloadData()
    }

    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension BlackListViewController: UITableViewDelegate, UITableViewDataSource, BlackListCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.blackList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlackListCell.self), for: indexPath) as? BlackListCell else { return UITableViewCell() }
        let blackUser = CoreDataManager.shared.blackList[indexPath.row]
        cell.userImage.sd_setImage(with: URL(string: blackUser.userImage), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        cell.userNameLabel.text = blackUser.userName
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableViewCellDidTapTrash(_ sender: BlackListCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        CoreDataManager.shared.removeFromBlackList(uid: CoreDataManager.shared.blackList[tappedIndexPath.row].uid)
    }
}
