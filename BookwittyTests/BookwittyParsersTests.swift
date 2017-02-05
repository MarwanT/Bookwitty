//
//  BookwittyParsersTests.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import XCTest
import Spine
@testable import Bookwitty


class BookwittyParsersTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testPenModelParser() {
    let penNameJson = "{\"data\":[{\"type\":\"pen-names\",\"id\":\"abcdef01-2345-6789-abcd-abcdef012345\",\"attributes\":{\"name\":\"John Doe\",\"biography\":\"Some stuff about John Doe\",\"avatar-url\":\"https://domain.com/image.jpg\",\"facebook-url\":\"https://facebook.com/bookwitty\",\"tumblr-url\":\"https://bookwitty.tumblr.com\",\"google-plus-url\":\"https://plus.google.com/+bookwitty\",\"twitter-url\":\"https://twitter.com/bookwitty\",\"instagram-url\":\"https://www.instagram.com/bookwitty/\",\"pinterest-url\":\"https://www.pinterest.com/bookwitty/\",\"youtube-url\":\"https://www.youtube.com/bookwitty\",\"linkedin-url\":\"https://www.linkedin.com/in/bookwitty\",\"wordpress-url\":\"https://bookwitty.wordpress.com/\",\"website-url\":\"https://example.com/\",\"followers-count\":235,\"following-count\":35.324, \"my-bool\":false},\"links\":{\"self\":\"/pen_names/abcdef01-2345-6789-abcd-abcdef012345\"}}],\"links\":{\"first\":\"/user/pen_names\",\"prev\":\"/user/pen_names?page[offset]=4\",\"self\":\"/user/pen_names?page[offset]=5\",\"next\":\"/user/pen_names?page[offset]=6\",\"last\":\"/user/pen_names?page[offset]=8\"}}"

    let penName = PenName.parseData(data: penNameJson.data(using: String.Encoding.utf8))

    XCTAssertNotNil(penName, "PenName model is null")
    XCTAssertEqual(penName!.followersCount!,235, "PenName followers was not 235")
    XCTAssertEqual(penName!.followingCount!,35.324, "PenName following was not 35.324")
  }
}

