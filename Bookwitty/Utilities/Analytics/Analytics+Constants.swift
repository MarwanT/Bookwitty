//
//  Analytics+Constants.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension Analytics {
  struct Event {
    let category: Category
    let action: Action
    let name: String
    let value: Double
  }
  
  enum Category {
    case Account
    case Quote
    case Image
    case Audio
    case Video
    case Link
    case ReadingList
    case Text
    case Topic
    case Author
    case TopicBook
    case BookProduct
    case PenName
    case NewsFeed
    case Discover
    case Search
    case BookStorefront
    case BookCategory
    case CategoriesList
    case Bag

  }
  
  enum Action {
  }
}
