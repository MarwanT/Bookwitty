//
//  GetStarted.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/11/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class GetStarted: ASDisplayNode {

  override init() {
    super.init()
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true
  }
}

//MARK: - Themeable Implementation
extension GetStarted: Themeable {
  func applyTheme() {
    //TODO: Empty Implementation
  }
}
