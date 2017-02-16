//
//  BookStoreViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class BookStoreViewModel {
  let viewAllCategoriesLabelText = localizedString(key: "view_all_categories", defaultValue: "View All Categories")
  let bookwittySuggestsTitle = localizedString(key: "bookwitty_suggests", defaultValue: "Bookwitty Suggests")
  let viewAllBooksLabelText = localizedString(key: "view_all_books", defaultValue: "View All Books")
  let viewAllSelectionsLabelText = localizedString(key: "view_all_selections", defaultValue: "View All Selections")
  let selectionHeaderTitle = localizedString(key: "our_selection_for_you", defaultValue: "Our selection for you")
}


// MARK: Featured Content

extension BookStoreViewModel {
  var featuredContentNumberOfItems: Int {
    return 7
  }
  
  func featuredContentValues(for indexPath: IndexPath) -> (title: String?, image: UIImage?) {
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
  
  func bookwittySuggestsValues(for indexPath: IndexPath) -> String {
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
