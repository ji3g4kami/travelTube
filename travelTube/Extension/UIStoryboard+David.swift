//
//  UIStoryboard+David.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static func videosStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Videos", bundle: nil)
    }

    static func postStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Post", bundle: nil)
    }

    static func searchStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Search", bundle: nil)
    }

    static func profileStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Profile", bundle: nil)
    }
}
