//
//  UIStoryboard+David.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/1.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static func feedStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Feed", bundle: nil)
    }

    static func postStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Post", bundle: nil)
    }

    static func anonymousProfileStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "AnonymousProfile", bundle: nil)
    }

    static func profileStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Profile", bundle: nil)
    }

    static func detailStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Detail", bundle: nil)
    }
}
