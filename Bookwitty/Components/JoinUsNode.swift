//
//  JoinUsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class JoinUsNode: ASDisplayNode {
  fileprivate let titleTextNode: ASTextNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let getStartedButtonNode: ASButtonNode
  fileprivate let alreadyHaveAnAccountTextNode: ASTextNode
  
  override init() {
    titleTextNode = ASTextNode()
    descriptionTextNode = ASTextNode()
    getStartedButtonNode = ASButtonNode()
    alreadyHaveAnAccountTextNode = ASTextNode()
    super.init()
  }
}
