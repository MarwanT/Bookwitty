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
  let bookDetailsNode = BookDetailsNode()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(with book: Book) {
    super.init(node: bookDetailsNode)
    viewModel.book = book
    bookDetailsNode.book = viewModel.book
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewController()
  }
  
  private func initializeViewController() {
    title = viewModel.viewControllerTitle
  }
}
