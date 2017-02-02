//
//  User.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class User {
  //TODO: Conform to Spine's Resource
  var firstName: String? = nil
  var lastName: String? = nil
  var dateOfBirth: String? = nil
  var password: String? = nil
  var email: String? = nil
  var country: String? = nil
  var createdAt: String? = nil
  var updatedAt: String? = nil
  var badges: [String: Any]? = nil
  var preferences: [String: Any]? = nil

  //TODO: override Spine's resourceType with type: 'users'
  //TODO: override fields and map user's properties
}
