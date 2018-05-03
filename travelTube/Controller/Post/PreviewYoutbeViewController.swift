//
//  PreviewYoutbeViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class PreviewYoutbeViewController: UIViewController {

    var YTId: String?
    
    @IBOutlet weak var youtubeId: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeId.text = YTId
    }
}
