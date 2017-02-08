//
//  RootTabbarViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class RootTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    //Set Default select tab index
    self.selectedIndex = 0

    let placeholderVc1 = UIViewController()
    let placeholderVc2 = UIViewController()

    //Set The View controller
    self.viewControllers = [UINavigationController(rootViewController: placeholderVc1),
                            UINavigationController(rootViewController: placeholderVc2)]
  }

}
