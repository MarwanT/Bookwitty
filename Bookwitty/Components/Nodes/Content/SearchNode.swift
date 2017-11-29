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
  fileprivate var searchBar: UISearchBar?

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
    applyTheme()
  }
  
  override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
    return CGSize(width: constrainedSize.width, height: SearchNode.cellHeight)
  }
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return searchBar?.becomeFirstResponder() ?? false
  }
  
  var text: String? {
    get { return searchBar?.text }
    set { searchBar?.text = newValue }
  }
}

extension SearchNode: Themeable {
  func applyTheme() {
    searchBar?.placeholder = Strings.search_placeholder()
    searchBar?.showsCancelButton = false
    searchBar?.searchBarStyle = .minimal
    searchBar?.barTintColor = .clear

    searchBar?.setTextColor(color: ThemeManager.shared.currentTheme.defaultTextColor())
    searchBar?.setTextFieldColor(color: ThemeManager.shared.currentTheme.colorNumber18().withAlphaComponent(0.7))
    searchBar?.setPlaceholderTextColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    searchBar?.setSearchImageColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    searchBar?.setTextFieldClearButtonColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
  }
}
