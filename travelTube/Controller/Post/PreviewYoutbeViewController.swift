//
//  PreviewYoutbeViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import  YouTubePlayer

class PreviewYoutbeViewController: UIViewController {

    var YTId: String = ""

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayer.playerVars = ["playsinline": 1] as YouTubePlayerView.YouTubePlayerParameters
        youtubePlayer.loadVideoID(YTId)
    }
}
