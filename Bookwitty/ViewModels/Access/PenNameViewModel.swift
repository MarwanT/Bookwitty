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
    return user.penNames?.first?.name ?? ""
  }

  func initializeWith(user: User) {
    self.user = user
  }
}
