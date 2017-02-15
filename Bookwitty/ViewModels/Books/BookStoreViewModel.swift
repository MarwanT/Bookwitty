//
//  BookStoreViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class BookStoreViewModel {
  let viewAllCategoriesLabelText = localizedString(key: "view-all-categories", defaultValue: "View All Categories")
  let bookwittySuggestsTitle = localizedString(key: "bookwitty-suggests", defaultValue: "Bookwitty Suggests")
  let selectionHeaderTitle = localizedString(key: "our_selection_for_you", defaultValue: "Our selection for you")
}


// MARK: Featured Content

extension BookStoreViewModel {
  var featuredContentNumberOfItems: Int {
    return 7
  }
  
  func dataForFeaturedContent(indexPath: IndexPath) -> (title: String?, image: UIImage?) {
    return ("Featuring Zouzou", #imageLiteral(resourceName: "Illustrtion"))
  }
}

// MARK: Bookwitty Suggests

extension BookStoreViewModel {
  var bookwittySuggestsNumberOfSections: Int {
    return 1
  }
  
  var bookwittySuggestsNumberOfItems: Int {
    return 4
  }
  
  func dataForBookwittySuggests(_ indexPath: IndexPath) -> String {
    return "Reading list \(indexPath.row)"
  }
}

// MARK: Bookwitty Selection

extension BookStoreViewModel {
  var selectionNumberOfSection: Int {
    return 1
  }
  
  var selectionNumberOfItems: Int {
    return 5
  }
  
  func selectionValues(for indexPath: IndexPath) -> (image: UIImage?, bookTitle: String?, authorName: String?, productType: String?, price: String?) {
    return (#imageLiteral(resourceName: "Illustrtion"), "Harry potter and the phylosopher's stone and shafic hariri", "J.K. Rowling And Many Many Other authors and famous people", "Paperback", "150,000 L.L")
  }
}
