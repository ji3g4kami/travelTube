//
//  YouTubeProvider.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation
import Alamofire
import YoutubeEngine

struct YoutubeProvider {
    // search youtube with ID
    func getDetails(of videoId: String) {
        let parameters: Parameters = ["part": "snippet",
                                      "id": videoId,
                                      "key": youtubeAPIKey]

        Alamofire.request(TTConstants.youtubeVideoUrl, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON(completionHandler: { (response) in
            if let data = response.result.value {
                print(data)
            }
        })

    }
}
