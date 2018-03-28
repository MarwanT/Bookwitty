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
  var language: String? = nil
  var oneTimeToken: String? = nil
  var badges: [String: Any]? = nil
  var preferences: [String: Any]? = nil
  var onboardCompleteAt: NSDate? = nil
  var onboardComplete: NSNumber? = nil

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
  //TODO: add primary address model

  @objc
  private var penNamesCollection: LinkedResourceCollection?
  lazy var penNames: [PenName]? = {
    return self.penNamesCollection?.resources as? [PenName]
  }()

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
      "language": Attribute().serializeAs("language"),
      "oneTimeToken" : Attribute().serializeAs("ott-token"),
      "onboardComplete": BooleanAttribute().serializeAs("onboard-complete"),
      "onboardCompleteAt": DateAttribute().serializeAs("onboard-complete-at"),
      "preferences" : PreferencesAttribute().serializeAs("preferences"),
      "penNamesCollection" : ToManyRelationship(PenName.self).serializeAs("pen-names")
      ])
  }
}

// MARK: - Utils
extension User {
  func isMy(penName: PenName) -> Bool {
   return self.penNames?.contains(where: { $0.id == penName.id }) ?? false
  }
}

// MARK: - Preferences
extension User {
  var emailNewsletter: Bool {
    guard let preferences = self.preferences else {
      return false
    }

    guard let newsletter = preferences[Preference.emailNewsletter.rawValue] as? String else {
      return false
    }

    //Negated because the preferences are unsub
    return !(newsletter.lowercased() == "true")
  }

  var emailNotificationsFollower: Bool {
    guard let preferences = self.preferences else {
      return false
    }

    guard let notification = preferences[Preference.emailNotificationFollowers.rawValue] as? String else {
      return false
    }

    //Negated because the preferences are unsub
    return !(notification.lowercased() == "true")
  }

  var emailNotificationsComments: Bool {
    guard let preferences = self.preferences else {
      return false
    }

    guard let notification = preferences[Preference.emailNotificationComments.rawValue] as? String else {
      return false
    }

    //Negated because the preferences are unsub
    return !(notification.lowercased() == "true")
  }

  var emailNotificationsWits: Bool {
    guard let preferences = self.preferences else {
      return false
    }

    guard let notification = preferences[Preference.emailNotificationWits.rawValue] as? String else {
      return false
    }

    //Negated because the preferences are unsub
    return !(notification.lowercased() == "true")
  }
}

// MARK: - Parser
extension User: Parsable {
  typealias AbstractType = User
}

extension User {
  enum Preference: String {
    case emailNotificationFollowers = "unsub-email-notification-followers"
    case emailNotificationComments = "unsub-email-notification-comments"
    case emailNotificationWits = "unsub-email-notification-votes"
    case emailNewsletter = "unsub-email-newsletter"
  }
}
