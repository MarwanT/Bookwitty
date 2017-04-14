//
//  ModelCommonActions.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 4/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol ModelCommonActions {
  var wit: Bool { get set }
  var dim: Bool { get set }
  var voteValue: String? { get set }
  var isFollowing: Bool { get set }
  var counts: Counts? { get }
}

