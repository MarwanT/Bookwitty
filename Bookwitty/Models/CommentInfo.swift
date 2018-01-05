//
//  CommentInfo.swift
//  Bookwitty
//
//  Created by Marwan  on 1/5/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation

struct CommentInfo {
  var id: String
  var avatarURL: URL?
  var fullName: String?
  var message: String?
  var isWitted: Bool
  var numberOfWits: Int?
  var createdAt: Date?
  var numberOfReplies: Int
}

//MARK: - Comment
//****\\
extension Comment {
  func info() -> CommentInfo? {
    guard let identifier = id else {
      return nil
    }
    return CommentInfo(id: identifier,
                       avatarURL: URL(string: penName?.avatarUrl ?? ""),
                       fullName: penName?.name,
                       message: body,
                       isWitted: isWitted,
                       numberOfWits: counts?.wits,
                       createdAt: createdAt as? Date,
                       numberOfReplies: counts?.children ?? 0)
  }
}
