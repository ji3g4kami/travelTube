//
//  SearchYoutubeViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage

class SearchYoutubeViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var videoTableView: UITableView!

    var youtubeArray = [Video]()
    var nextPageToken: String?
    var youtubeManager = YoutubeManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeManager.delegate = self

        videoTableView.delegate = self
        videoTableView.dataSource = self

        searchBar.delegate = self

    }
}

extension SearchYoutubeViewController: YoutubeManagerDelegate {
    func manager(_ manager: YoutubeManager, didGet videos: [Video], _ paging: String?) {
        nextPageToken = paging
        youtubeArray += videos
        self.videoTableView.reloadData()
    }
}

extension SearchYoutubeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            youtubeArray.removeAll()
            youtubeManager.searchYouTube(of: searchText)
        }
    }
}

extension SearchYoutubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return youtubeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = videoTableView.dequeueReusableCell(withIdentifier: "SearchYoutubeResultCell") as? SearchYoutubeResultCell else { return UITableViewCell() }
        cell.titleLabel.text = youtubeArray[indexPath.row].title
        cell.videoCoverImage.sd_setImage(with: URL(string: youtubeArray[indexPath.row].image), placeholderImage: #imageLiteral(resourceName: "youtube"))
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == youtubeArray.count-1 {
            youtubeManager.continueSearch(pageToken: nextPageToken)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(youtubeArray[indexPath.row].youtubeId)
        performSegue(withIdentifier: "fromSearchToPreview", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostArticleViewController, let indexPath = videoTableView.indexPathForSelectedRow?.row {
            destination.youtube = youtubeArray[indexPath]
        }
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
