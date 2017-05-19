//
//  UIBarButtonItem+Utils.swift
//  Bookwitty
//
//  Created by charles on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

  /**
   A convenience var to ease the creation of the navigation bar back button
   - returns: a `UIBarButtonItem` instance with empty title
   */
  public static var back: UIBarButtonItem {
    return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
  
  var frame: CGRect? {
    guard let view = self.value(forKey: "view") as? UIView else {
      return nil
    }
    return view.frame
  }
}
