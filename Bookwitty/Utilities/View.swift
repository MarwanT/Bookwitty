//
//  View.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension UIView {
  public static var defaultNib: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
  
  public static func loadFromView<V: UIView>(_ view: V.Type, owner: Any?) -> V {
    let defaultNib = view.defaultNib
    guard let viewInstance = Bundle.main.loadNibNamed(
      defaultNib,
      owner: owner,
      options: nil)?[0] as? V else {
      fatalError("Couldn't load view with nibName '\(defaultNib)'")
    }
    return viewInstance
  }
  
  /** 
   This method is to be called from
   
   `func awakeAfter(using aDecoder: NSCoder) -> Any?`
   
   Load a view from its relative nib file in case the view was 
   integrated in the storyboard. Otherwise the view will be blank.
  */
  func viewForNibNameIfNeeded(nibName: String) -> Any? {
    let isJustAPlaceholder = self.subviews.count == 0
    
    guard isJustAPlaceholder else {
      return self
    }
    
    guard let view = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?[0] as? UIView else {
      fatalError("Couldn't load view with nibName '\(nibName)'")
    }
    
    view.autoresizingMask = self.autoresizingMask
    view.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints
    
    for constraint in self.constraints {
      var firstItem = constraint.firstItem as? NSObject
      if firstItem == self {
        firstItem = view
      }
      
      var secondItem = constraint.secondItem as? NSObject
      if secondItem == self {
        secondItem = view
      }
      
      let newConstraint = NSLayoutConstraint(
        item: firstItem!,
        attribute: constraint.firstAttribute,
        relatedBy: constraint.relation,
        toItem: secondItem,
        attribute: constraint.secondAttribute,
        multiplier: constraint.multiplier,
        constant: constraint.constant)
      
      view.addConstraint(newConstraint)
    }
    
    self.removeConstraints(self.constraints)
    
    return view
  }

  static func defaultSeparator(useAutoLayout: Bool = true) -> UIView {
    let separator = UIView(frame: CGRect.zero)
    if useAutoLayout {
      separator.constrainHeight("1")
    } else {
      separator.frame.size.height = 1
    }
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    return separator
  }
  
  var containsFirstResponder: Bool {
    if isFirstResponder { return true }
    for view in subviews {
      if view.containsFirstResponder { return true }
    }
    return false
  }
}
