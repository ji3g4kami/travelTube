//
//  DetailViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    var youtubeId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = youtubeId {
            youtubePlayer.loadVideoID(youtubeId)
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
