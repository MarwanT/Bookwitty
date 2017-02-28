//
//  RootTabBarViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class RootTabBarViewModel {
  let bookStoreTabTitle = Strings.books()
  
  var isUserSignedIn: Bool {
    return AccessToken.shared.hasTokens
  }
}
