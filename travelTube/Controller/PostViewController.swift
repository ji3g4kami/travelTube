//
//  PostViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage

class PostViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var videoTableView: UITableView!

    var youtubeArray = [Video]()

    var youtubeManager = YoutubeManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubeManager.delegate = self

        videoTableView.delegate = self
        videoTableView.dataSource = self

        searchBar.delegate = self

    }
}

extension PostViewController: YoutubeManagerDelegate {
    func manager(_ manager: YoutubeManager, didGet videos: [Video], _ paging: Int?) {
        youtubeArray += videos
        self.videoTableView.reloadData()
    }
}

extension PostViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        youtubeManager.searchYouTube(of: searchText)
        videoTableView.reloadData()
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return youtubeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = videoTableView.dequeueReusableCell(withIdentifier: "videoCell") as? VideoCell else { return UITableViewCell() }
        cell.titleLabel.text = youtubeArray[indexPath.row].title
        cell.videoCoverImage.sd_setImage(with: URL(string: youtubeArray[indexPath.row].image), placeholderImage: #imageLiteral(resourceName: "youtube"))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}

class Video {
    let youtubeId: String
    let title: String
    let image: String
    let publishDate: TimeInterval

    init(youtubeId: String, title: String, image: String, publishDate: TimeInterval) {
        self.youtubeId = youtubeId
        self.title = title
        self.image = image
        self.publishDate = publishDate
    }
}
