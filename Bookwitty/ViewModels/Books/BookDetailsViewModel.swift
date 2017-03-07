//
//  BookDetailsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

enum BookDetailsSection: Int {
  case header = 0
  case format
  case eCommerce
  case about
  case serie
  case peopleWhoLikeThisBook
  case details
  case categories
  case recommendedReadingLists
  case relatedTopics
}

final class BookDetailsViewModel {
  var book: Book! = nil
  
  var viewControllerTitle: String? {
    return ""
  }
}
