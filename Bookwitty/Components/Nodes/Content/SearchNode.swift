//
//  SearchNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/27.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SearchNode: ASCellNode {
  static let cellHeight: CGFloat = 44.0

  var searchBarDelegate: UISearchBarDelegate?
  private var searchBar: UISearchBar?

  convenience override init() {
    self.init(viewBlock: { () -> UIView in
      let searchBar = UISearchBar()
      return searchBar
    })
    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: SearchNode.cellHeight)
  }

  override func didLoad() {
    self.searchBar = self.view as? UISearchBar
    self.searchBar?.delegate = searchBarDelegate
  }

  override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
    return CGSize(width: constrainedSize.width, height: SearchNode.cellHeight)
  }
}
