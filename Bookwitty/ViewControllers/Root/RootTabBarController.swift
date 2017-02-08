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

    let feeds: UIImage = UIImage(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "newsfeed"))!, scale: 4)!
    let post: UIImage = UIImage(data: UIImagePNGRepresentation( #imageLiteral(resourceName: "createPost"))!, scale: 4)!
    
    placeholderVc1.tabBarItem = UITabBarItem(
      title: "NEWS",
      image: feeds,
      tag: 1)
    placeholderVc2.tabBarItem = UITabBarItem(
      title: "POST",
      image: post,
      tag:2)

    //Set The View controller
    self.viewControllers = [UINavigationController(rootViewController: placeholderVc1),
                            UINavigationController(rootViewController: placeholderVc2)]
  }

}
