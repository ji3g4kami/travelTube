//
//  YouTubeProvider.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation
import Alamofire

private enum YoutubeAPI {
    case getDetails(String)
}

struct YoutubeProvider {
    static func getDetails(of id: String){
        let parameters: Parameters = ["part":"snippet",
                                      "id": id,
                                      "key": YOUTUBE_DATA_API_KEY]
//        let url = "https://www.googleapis.com/youtube/v3/videos"
        
        Alamofire.request(TTConstants.youtubeVideoUrl, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON(completionHandler: { (response) in
            print(response.result.value)
            
        })
        
    }
}
