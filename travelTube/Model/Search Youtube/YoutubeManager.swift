//
//  YoutubeManager.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/2.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import YoutubeEngine

protocol YoutubeManagerDelegate: class {
    func manager(_ manager: YoutubeManager, didGet videos: [Video], _ paging: Int?)
}

class YoutubeManager {

    weak var delegate: YoutubeManagerDelegate?

    var videos = [Video]()

    func searchYouTube(of searchText: String) {
        let engine = Engine(.key(youtubeAPIKey))
        let request = Search(.term(searchText, [.video: [.snippet]]))
        engine.search(request).startWithResult { (result) in
            guard case .success(let page) = result else {
                return
            }

            for videoItem in page.items {
                if let youtubeId = videoItem.video?.id, let title = videoItem.video?.snippet?.title, let image = videoItem.video?.snippet?.defaultImage.url.absoluteString, let publishDate = videoItem.video?.snippet?.publishDate.timeIntervalSince1970 {
                    let video = Video(youtubeId: youtubeId, title: title, image: image, publishDate: publishDate)
                    self.videos.append(video)
                }
            }
            DispatchQueue.main.async {
                self.delegate?.manager(self, didGet: self.videos, 0)
                self.videos.removeAll()
            }
        }
    }
}
