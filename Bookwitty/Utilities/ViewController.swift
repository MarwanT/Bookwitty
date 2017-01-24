//
//  ViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension UIViewController {
  func add(asChildViewController viewController: UIViewController, toView view: UIView) -> UIView {
    guard let childView = viewController.view else {
      return UIView()
    }
    
    // Add Child View Controller
    addChildViewController(viewController)
    
    // Add Child View As Subview
    view.addSubview(childView)
    
    // Notify Child View Controller
    viewController.didMove(toParentViewController: self)
    
    return childView
  }
}
