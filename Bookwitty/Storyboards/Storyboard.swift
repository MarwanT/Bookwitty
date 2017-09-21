//
//  Storyboard.swift
//  Bookwitty
//
//  Created by Marwan  on 1/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

enum Storyboard: String {
  case Introduction
  case Access
  case Root
  case Books
  case Account
  case Misc
  case Details
    
  public func instantiate<VC: UIViewController>(_ viewController: VC.Type,
                   inBundle bundle: Bundle? = nil) -> VC {
    guard let vc = UIStoryboard(name: self.rawValue, bundle: bundle).instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC else {
      fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)")
    }
    return vc
  }
}
