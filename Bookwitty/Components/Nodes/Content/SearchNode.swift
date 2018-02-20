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
  
  var configuration = Configuration() {
    didSet {
      if isNodeLoaded {
        applyTheme()
      }
    }
  }

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

    searchBar?.setTextColor(color: configuration.textColor)
    searchBar?.setPlaceholderTextColor(color: configuration.placeholderTextColor)
    searchBar?.setSearchImageColor(color: configuration.searchImageColor)
    searchBar?.setTextFieldClearButtonColor(color: configuration.textFieldClearButtonColor)
    searchBar?.setTextFieldColor(color: UIColor.white)
  }
}

extension SearchNode {
  struct Configuration {
    var textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var textFieldColor = ThemeManager.shared.currentTheme.colorNumber23()
    var placeholderTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    var searchImageColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    var textFieldClearButtonColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
  }
}
