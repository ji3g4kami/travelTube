//
//  Constants.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

struct TTConstants {
    static let youtubeVideoUrl = "https://www.googleapis.com/youtube/v3/videos"
}

enum TTColor: String {
    case tabBarTintColor = "428DFF"
    case lightGray = "E7E7E7" // 231, 231, 231
    case darkGray = "CDCDCD"  // 205, 205, 205

    func color() -> UIColor {

        var cString: String = self.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )

    }
}
