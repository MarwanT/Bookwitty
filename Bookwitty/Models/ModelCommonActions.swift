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

extension ModelCommonActions {
  var wit: Bool {
    get {
      guard let vote = voteValue else {
        return false
      }
      return Vote.isWitted(vote: vote)
    }
    set {
      let wasDimmed = dim
      //Set Value
      voteValue = Vote.witted.rawValue

      guard let counts = counts else {
        return
      }
      counts.wits = (counts.wits ?? 0) + 1
      if wasDimmed {
        counts.dims = (counts.dims ?? 1) - 1
      }
    }
  }

  var dim: Bool {
    get {
      guard let vote = voteValue else {
        return false
      }
      return Vote.isDimmed(vote: vote)
    }
    set {
      let wasWitted = wit
      //Set Value
      voteValue = Vote.dimmed.rawValue

      guard let counts = counts else {
        return
      }
      counts.dims = (counts.dims ?? 0) + 1
      if wasWitted {
        counts.wits = (counts.wits ?? 1) - 1
      }
    }
  }
}

// MARK: - Video
extension Video: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

