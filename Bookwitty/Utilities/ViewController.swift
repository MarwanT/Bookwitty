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
  
  func remove(asChildViewController viewController: UIViewController) {
    // Notify Child View Controller
    viewController.willMove(toParentViewController: nil)
    
    // Remove Child View From Superview
    viewController.view.removeFromSuperview()
    
    // Notify Child View Controller
    viewController.removeFromParentViewController()
  }


  func presentShareSheet(shareContent: [Any]) {
    let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
  }
  
  func showAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.ok(), style: UIAlertActionStyle.default, handler: handler))
    self.present(alert, animated: true, completion: nil)
  }

  func pushProfileViewController(penName: PenName) {
    let viewModel = ProfileDetailsViewModel(penName: penName)
    let profileVC = ProfileDetailsViewController.create(with: viewModel)
    self.navigationController?.pushViewController(profileVC, animated: true)
  }

  func pushPenNamesListViewController(with resource: ModelResource) {
    /// Uncoment the following line to access list of pen names
    let penNamesListVC = PenNameListViewController()
    penNamesListVC.initializeWith(resource: resource)
    self.navigationController?.pushViewController(penNamesListVC, animated: true)
  }

  func pushCommentsViewController(for resource: ModelCommonProperties?) {
    guard let identifier = resource?.id else {
      return
    }

    let commentsManager = CommentsManager()
    commentsManager.initialize(postIdentifier: identifier)

    let commentsVC = CommentsViewController()
    commentsVC.initialize(with: commentsManager)
    self.navigationController?.pushViewController(commentsVC, animated: true)
  }
}

extension UIViewController {
  public static var defaultNib: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
  
  public static var storyboardIdentifier: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
}
