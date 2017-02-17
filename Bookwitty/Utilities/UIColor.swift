//
//  UIColor.swift
//  Bookwitty
//
//  Created by Marwan  on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation


extension UIColor {
  func image(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
    return UIImage(color: self, size: size)
  }
}
