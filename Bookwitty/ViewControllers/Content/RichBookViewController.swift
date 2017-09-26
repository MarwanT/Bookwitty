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
    loadNavigationBarButtons()
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
    
  }
  
  @objc private func add(_ sender: UIBarButtonItem) {
    
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
}
