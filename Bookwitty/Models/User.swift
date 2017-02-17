//
//  User.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class User: Resource {
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


  /* Discussion
  * Only ussed to verify password update
  */
  var currentPassword: String? = nil

  //TODO: add cart model
  //TODO: add orders array model
  //TODO: add affiliate profiles array model
  //TODO: add tapffiliate profiles array model
  //TODO: add addresses model array
  //TODO: add payment methods model array
  //TODO: add pen names methods model array
  //TODO: add primary address model

  override class var resourceType: ResourceType {
    return "users"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "firstName": Attribute().serializeAs("first-name"),
      "lastName": Attribute().serializeAs("last-name"),
      "email": Attribute().serializeAs("email"),
      "dateOfBirth": Attribute().serializeAs("date-of-birth"),
      "country": Attribute().serializeAs("country"),
      "password": Attribute().serializeAs("password"),
      "currentPassword": Attribute().serializeAs("current-password"),
      ])
  }

}

// MARK: - Parser
extension User: Parsable {
  typealias AbstractType = User
}
