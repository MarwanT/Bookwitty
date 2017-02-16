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
    
    applyTheme()
    addObservers()
    
    //Set Default select tab index
    self.selectedIndex = 0

    let placeholderVc1 = NewsFeedViewController()
    let placeholderVc2 = UIViewController()
    
    placeholderVc1.tabBarItem = UITabBarItem(
      title: "NEWS",
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    placeholderVc2.tabBarItem = UITabBarItem(
      title: "POST",
      image: #imageLiteral(resourceName: "createPost"),
      tag:2)

    //Set The View controller
    self.viewControllers = [UINavigationController(rootViewController: placeholderVc1),
                            UINavigationController(rootViewController: placeholderVc2)]
  }

  private func addObservers() {
  }

}

extension RootTabBarController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

//MARK: - Notifications
extension RootTabBarController {
}
