//
//  OnBoardingViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingViewController: ASViewController<ASDisplayNode> {
  let onBoardingNode: ASDisplayNode

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    onBoardingNode = ASDisplayNode()
    super.init(node: onBoardingNode)
  }

}
