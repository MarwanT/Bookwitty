//
//  TopicViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class TopicViewModel {
  var topic: Topic?

  fileprivate var latest: [ModelResource] = []
  fileprivate var editions: [Book] = []
  fileprivate var relatedBooks: [Book] = []
  fileprivate var followers: [PenName] = []

}
