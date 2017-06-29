//
//  UniColorSectionHeaderView.swift
//  Bookwitty
//
//  Created by Marwan  on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

class UniColorSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "UniColorSectionHeaderView"
  
  fileprivate var topSeparator: UIView!
  fileprivate var bottomSeparator: UIView!
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    initializeView()
    applyTheme()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initializeView() {
    topSeparator = separatorViewInstance()
    bottomSeparator = separatorViewInstance()
    contentView.addSubview(topSeparator)
    contentView.addSubview(bottomSeparator)
    
    topSeparator.alignTop("0", leading: "0", toView: contentView)
    topSeparator.constrainWidth(toView: contentView, predicate: "0")
    bottomSeparator.alignBottom("0", trailing: "0", toView: contentView)
    bottomSeparator.constrainWidth(toView: contentView, predicate: "0")
  }
  
  fileprivate func separatorViewInstance() -> UIView {
    let separatorView = UIView(frame: CGRect.zero)
    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separatorView.constrainHeight("1")
    return separatorView
  }
}

extension UniColorSectionHeaderView: Themeable {
  func applyTheme() {
    textLabel?.font = FontDynamicType.subheadline.font
    textLabel?.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}
