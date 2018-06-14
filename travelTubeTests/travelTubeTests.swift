//
//  travelTubeTests.swift
//  travelTubeTests
//
//  Created by 吳登秝 on 2018/6/14.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import XCTest
@testable import travelTube

class TravelTubeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testArticleCount() {
        FirebaseManager.shared.getAllFeeds { (articles) in
            XCTAssertEqual(articles.count, 9)
        }
    }

}
