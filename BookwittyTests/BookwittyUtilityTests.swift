//
//  BookwittyUtilityTests.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import XCTest
import Moya
@testable import Bookwitty


class BookwittyUtilityTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testPasswordValidation() {
    XCTAssertTrue("1234567".isValidPassword(), "This password was 7 characters long, it should not have failed.")
    XCTAssertFalse("123456".isValidPassword(), "Password with 6 character only should not pass.")
    XCTAssertFalse("".isValidPassword(), "Empty password should not pass.")
    XCTAssertFalse(" ".isValidPassword(), "Blank password should not pass.")
  }

  func testFirstNameValidation() {
    XCTAssertTrue("Shafic".isValidText(),"First name shafic should pass.")
    XCTAssertTrue(" S ".isValidText(), "1 Character name should pass.")
    XCTAssertFalse("    ".isValidText(), "Blank name should not pass.")
    XCTAssertFalse("".isValidText(), "Empty name should not pass.")
  }

  func testLastNameValidation() {
    XCTAssertTrue("Hariri".isValidText(),"Last name hariri should pass.")
    XCTAssertTrue(" H ".isValidText(), "1 Character with spaces name should pass.")
    XCTAssertTrue("H ".isValidText(), "1 Character name should pass.")
    XCTAssertFalse("    ".isValidText(), "Blank name should not pass.")
    XCTAssertFalse("".isValidText(), "Empty name should not pass.")
  }

  func testEmailValidation() {
    XCTAssertTrue("shafic.hariri@keeward.com".isValidEmail(),"Valid email format should pass.")
    XCTAssertFalse("shafic hariri@keeward.com".isValidEmail(),"Invalid email format should not pass. [has space]")
    XCTAssertFalse("shafic.haririkeeward.com".isValidEmail(),"Invalid email format should not pass. [no @]")
    XCTAssertFalse("shafic.hariri@keewardcom".isValidEmail(),"Invalid email format should not pass. [no domain]")
    XCTAssertFalse("@keeward.com".isValidEmail(),"Invalid email format should not pass. [no name]")
    XCTAssertFalse("keeward.com".isValidEmail(),"Invalid email format should not pass. [no name/no @]")
    XCTAssertFalse("".isValidEmail(),"Empty email should not pass.")
  }
}
