//
//  DetailViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer
import AMScrollingNavbar

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tableView: UITableView!
    var youtubeId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = youtubeId {
            youtubePlayer.loadVideoID(youtubeId)
        }
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToSearch))
        self.navigationItem.leftBarButtonItem = newBackButton

        // Do any additional setup after loading the view.
    }

    @objc func backToSearch() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 0.0)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
