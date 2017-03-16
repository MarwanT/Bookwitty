//
//  MisfortuneNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class MisfortuneNode: ASDisplayNode {
}

// MARK: - Mode Declaration
extension MisfortuneNode {
  enum Mode {
    case noInternet
    case empty
    case somethingWrong
    case noResultsFound
  }
}
