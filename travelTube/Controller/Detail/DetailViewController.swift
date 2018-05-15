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
    var youtube: Video?

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = youtube?.youtubeId, let youtubeTitle = youtube?.title {
            youtubePlayer.loadVideoID(youtubeId)
            self.navigationItem.title = youtubeTitle
        }

        // Do any additional setup after loading the view.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
