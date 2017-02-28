//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PenNameViewModel {
  private(set) var user: User!

  func penDisplayName() -> String {
    let firstName = user.firstName ?? ""
    let lastName = user.lastName ?? ""
    return firstName + " " + lastName
  }

  func initializeWith(user: User) {
    self.user = user
  }
}
