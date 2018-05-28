//
//  VideoPopupViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/28.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoPopupViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    var youtubeId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let youtubeId = youtubeId else { return }
        setupYoutubePlayer(of: youtubeId)
    }

    func setupYoutubePlayer(of youtubeId: String) {
        youtubePlayer.playerVars = ["playsinline": "1", "showinfo": "0", "modestbranding": "1"] as YouTubePlayerView.YouTubePlayerParameters
        youtubePlayer.loadVideoID(youtubeId)
    }
}
