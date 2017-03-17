//
//  ProfileDetailsViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class ProfileDetailsViewModel {
  let penName: PenName

  var latestData: [ModelResource] = []
  var followers: [ModelResource] = []
  var following: [ModelResource] = []

  init(penName: PenName) {
    self.penName = penName
  }

}
