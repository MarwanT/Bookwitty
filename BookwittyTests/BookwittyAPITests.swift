//
//  BookwittyAPITests.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import XCTest
import Moya
@testable import Bookwitty


class BookwittyAPITests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testAllAddressesAPIRequest() {
    let excep = expectation(description: "...")
    
    _ = apiRequest(target: BookwittyAPI.allAddresses) {
      (data, statusCode, response, error) in
      
      XCTAssertEqual(statusCode, 200)
      XCTAssertNotNil(data)
      XCTAssertNotNil(response)
      XCTAssertNil(error)
      
      excep.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      // ...
    }
  }
  
  func testSignInAPIRequest() {
    let excep = expectation(description: "...")
    
    _ = UserAPI.signIn(
      with: .bookwitty(username: "danny.hajj@keeward.com", password: "qwerty1234")) {
        (success, error) in
        XCTAssertTrue(success)
        XCTAssertNil(error)
        
        excep.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      // ...
    }
  }
  
  func testUserAPIRequest() {
    let excep = expectation(description: "...")
    
    _ = signedAPIRequest(target: BookwittyAPI.user) {
      (data, statusCode, response, error) in
      
      XCTAssertEqual(statusCode, 200)
      XCTAssertNotNil(data)
      XCTAssertNotNil(response)
      XCTAssertNil(error)
      
      excep.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      // ...
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
