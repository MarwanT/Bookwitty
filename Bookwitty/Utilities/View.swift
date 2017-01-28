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
}
