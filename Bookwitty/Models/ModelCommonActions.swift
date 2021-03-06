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
      //Set Value
      voteValue = newValue ? Vote.Options.witted.rawValue : ""

      guard let counts = counts else {
        return
      }
      counts.wits = (counts.wits ?? 0) + (newValue ? 1 : -1)
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

// MARK: - Topic
extension Topic: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return following }
    set {
      following = newValue
      guard let counts = counts else {
        return
      }
      if following {
        counts.followers = (counts.followers ?? 0) + 1
      } else {
        counts.followers = (counts.followers ?? 1) - 1
      }
    }
  }
}

// MARK: - Image
extension Image: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - Author
extension Author: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return following }
    set {
      following = isFollowing
      guard let counts = counts else {
        return
      }
      if following {
        counts.followers = (counts.followers ?? 0) + 1
      } else {
        counts.followers = (counts.followers ?? 1) - 1
      }
    }
  }
}

// MARK: - Link
extension Link: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - ReadingList
extension ReadingList: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - Audio
extension Audio: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - Text
extension Text: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - Quote
extension Quote: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }

  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}

// MARK: - Book
extension Book: ModelCommonActions {
  var voteValue: String? {
    get { return nil }
    set { /* Do Nothing - Action not valid on model */ }
  }

  var isFollowing: Bool {
    get { return following }
    set {
      following = newValue
      guard let counts = counts else {
        return
      }
      if following {
        counts.followers = (counts.followers ?? 0) + 1
      } else {
        counts.followers = (counts.followers ?? 1) - 1
      }
    }
  }
}

// MARK: - PenName
extension PenName: ModelCommonActions {
  var voteValue: String? {
    get { return nil }
    set { /* Do Nothing - Action not valid on model */ }
  }

  var isFollowing: Bool {
    get { return following }
    set {
      following = newValue
      guard let counts = counts else {
        return
      }
      if following {
        counts.followers = (counts.followers ?? 0) + 1
      } else {
        counts.followers = (counts.followers ?? 1) - 1
      }
    }
  }
}

// MARK: - Comment
extension Comment: ModelCommonActions {
  var voteValue: String? {
    get { return vote }
    set { vote = newValue }
  }
  
  var isFollowing: Bool {
    get { return false }
    set { /* */ }
  }
}
