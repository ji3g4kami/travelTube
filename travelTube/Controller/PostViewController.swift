//
//  PostViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import ReactiveSwift

class PostViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var videoTableView: UITableView!

    var videoArray = [Video]()
    var filteredVideoArray = [Video]()

    final class YoutubeViewModel {
        let keyword = MutableProperty("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideo()

        videoTableView.delegate = self
        videoTableView.dataSource = self

        searchBar.delegate = self

    }

    private func setupVideo() {
        videoArray.append(Video(title: "video", cover: "youtube"))
        videoArray.append(Video(title: "search", cover: "search"))
        videoArray.append(Video(title: "post", cover: "news"))
        videoArray.append(Video(title: "profile", cover: "user"))

        filteredVideoArray = videoArray
    }

}

extension PostViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredVideoArray = videoArray
            videoTableView.reloadData()
            return
        }
        filteredVideoArray = videoArray.filter({ video -> Bool in
            return video.title.lowercased().contains(searchText.lowercased())
        })
        videoTableView.reloadData()
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVideoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = videoTableView.dequeueReusableCell(withIdentifier: "videoCell") as? VideoCell else { return UITableViewCell() }
        cell.titleLabel.text = filteredVideoArray[indexPath.row].title
        cell.videoCoverImage.image = UIImage(named: filteredVideoArray[indexPath.row].cover)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}

class Video {
    let title: String
    let cover: String

    init(title: String, cover: String) {
        self.title = title
        self.cover = cover
    }
}
