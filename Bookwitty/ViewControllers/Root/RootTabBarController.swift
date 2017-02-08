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
    //Hide top navigation bar - Each tab will have its own.
    self.navigationController?.navigationBar.isHidden = true
    //Set Default select tab index
    self.selectedIndex = 0
  }

}
