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
  //TODO: add cart model
  //TODO: add orders array model
  //TODO: add affiliate profiles array model
  //TODO: add tapffiliate profiles array model
  //TODO: add addresses model array
  //TODO: add payment methods model array
  //TODO: add pen names methods model array
  //TODO: add primary address model

  //TODO: override Spine's resourceType with type: 'users'
  //TODO: override fields and map user's properties
}
