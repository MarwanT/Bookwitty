//
//  OnBoardingLoadingButton.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit


class OnBoardingLoadingButton: ASDisplayNode {
  let loaderNode: LoaderNode
  let button: ASButtonNode

  override init() {
    loaderNode = LoaderNode()
    button = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupSelectionButton()
  }

  func setupSelectionButton() {
  }

}
