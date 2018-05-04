//
//  PreviewYoutbeViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer
import KSTokenView

class PreviewYoutbeViewController: UIViewController {

    var youtubeId: String = ""
    let names: [String] = ["Taiwan", "Delicacy", "History"]

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tokenView: KSTokenView!

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        youtubePlayer.loadVideoID(youtubeId)

        setupTokenView()
    }
}

extension PreviewYoutbeViewController: KSTokenViewDelegate {

    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }

    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    func setupTokenView() {
        tokenView.delegate = self
        tokenView.promptText = " Tags: "
        tokenView.placeholder = " 3 tags at most"
        tokenView.maxTokenLimit = 3
        tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
        tokenView.style = .rounded
        tokenView.direction = .vertical
        tokenView.cursorColor = .black
        tokenView.paddingY = 10
        tokenView.marginY = tokenView.paddingY
        tokenView.searchResultHeight = 120
    }

    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: [AnyObject]) -> Void)?) {
        if string.isEmpty {
            completion!(names as [AnyObject])
            return
        }

        var data: [String] = []
        for value: String in names {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)
            }
        }
        completion!(data as [AnyObject])
    }

    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        guard let obj = object as? String else {
            return ""
        }
        return obj
    }
}
