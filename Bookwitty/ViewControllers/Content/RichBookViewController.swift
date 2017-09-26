//
//  RichBookViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class RichBookViewController: ASViewController<ASCollectionNode> {
  
  var searchBar: UISearchBar?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    self.hideNavigationShadowImage()
    loadNavigationBarButtons()
    configureSearchBar()
    searchBar?.becomeFirstResponder()
  }
  
  private func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    
    let cancel = UIBarButtonItem(title: Strings.cancel(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.cancel(_:)))
    cancel.tintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    
    let add = UIBarButtonItem(title: Strings.add(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(self.add(_:)))
    setTextAppearanceState(of: add)

    navigationItem.leftBarButtonItem = cancel
    navigationItem.rightBarButtonItem = add
  }
  
  @objc private func cancel(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func add(_ sender: UIBarButtonItem) {
    
  }
  
  private func hideNavigationShadowImage() {
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
  }
  @objc private func setTextAppearanceState(of barButtonItem: UIBarButtonItem) -> Void {
    
    var attributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]
    //Normal
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    attributes[NSForegroundColorAttributeName] = defaultTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .normal)
    //Disabled
    let grayedTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    attributes[NSForegroundColorAttributeName] = grayedTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .disabled)
  }
  
  func configureSearchBar() {
    searchBar = UISearchBar()
    searchBar?.translatesAutoresizingMaskIntoConstraints = false
    if let searchBar = self.searchBar {
      self.view.addSubview(searchBar)
      NSLayoutConstraint.activate([
        searchBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
        searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    searchBar?.placeholder = Strings.search_placeholder()
    searchBar?.delegate = self
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

extension RichBookViewController: UISearchBarDelegate {
  
}
