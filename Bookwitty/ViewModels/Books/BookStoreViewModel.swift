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
