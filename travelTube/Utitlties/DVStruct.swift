//
//  DVStruct.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/14.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

struct Article: Codable {
    var annotations: [Annotation]
    var tag: [String]?
    let uid: String
    let articleId: String
    var updateTime: Date
    let youtubeId: String
    let youtubeImage: String
    let youtubePublishDate: Date
    let youtubeTitle: String
}

struct Annotation: Codable {
    let latitude: Double
    let logitutde: Double
    let title: String
}

struct PreserveArticle {
    let articleId: String
    let youtubeId: String
    let tags: [String]
    let youtubeImage: String
    let youtubeTitle: String
}

struct Comment {
    let commentId: String
    var comment: String
    let createdTime: TimeInterval
    let userId: String
    let userName: String
    let userImage: String
}

struct BlackListUser {
    let uid: String
    let userName: String
    let userImage: String
}
