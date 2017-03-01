//
//  BookDetailsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BookDetailsViewController: ASViewController<ASDisplayNode> {
  let viewModel = BookDetailsViewModel()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init() {
    let baseNode = ASDisplayNode()
    super.init(node: baseNode)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewController()
  }
  
  private func initializeViewController() {
    title = viewModel.viewControllerTitle
  }
}
