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

    var name: String {
      switch self {
      case .Account:
        return "Account"
      case .Quote:
        return "Quote"
      case .Image:
        return "Image"
      case .Audio:
        return "Audio"
      case .Video:
        return "Video"
      case .Link:
        return "Link"
      case .ReadingList:
        return "Reading List"
      case .Text:
        return "Text"
      case .Topic:
        return "Topic"
      case .Author:
        return "Author"
      case .TopicBook:
        return "Topic Book"
      case .BookProduct:
        return "Book Product"
      case .PenName:
        return "Pen Name"
      case .NewsFeed:
        return "News Feed"
      case .Discover:
        return "Discover"
      case .Search:
        return "Search"
      case .BookStorefront:
        return "Book Storefront"
      case .BookCategory:
        return "Book Category"
      case .CategoriesList:
        return "Categories List"
      case .Bag:
        return "Bag"
      }
    }
  }
  
  enum Action {
  }
}
