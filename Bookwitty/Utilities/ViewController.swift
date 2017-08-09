//
//  ViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension UIViewController {

  enum ReportType: Int {
    case content = 0
    case penName = 1
  }

  enum MoreAction {
    case report(ReportType)
  }

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

  func showMoreActionSheet(identifier: String, actions: [MoreAction], completion: @escaping (_ success: Bool)->()) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

    if actions.contains(where: { $0 == .report(.content) }) {
      alert.addAction(UIAlertAction(title: Strings.report(), style: .destructive, handler: { (action: UIAlertAction) in
        self.showReportContentAlert(identifier: identifier, completion: { (success: Bool) in
          completion(success)
        })
      }))
    }

    if actions.contains(where: { $0 == .report(.penName) }) {
      alert.addAction(UIAlertAction(title: Strings.report(), style: .destructive, handler: { (action: UIAlertAction) in
        self.showReportPenNameAlert(identifier: identifier, completion: { (success: Bool) in
          completion(success)
        })
      }))
    }

    alert.addAction(UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  func showReportContentAlert(identifier: String, completion: @escaping (_ success: Bool)->()) {
    let title = Strings.report()
    let message = Strings.report_this_content()
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.yes_this_is_spam(), style: .destructive, handler: { (action: UIAlertAction) in
      //TODO: Send Report
      self.showReportSuccessfullAlert(completion: { 
        completion(true)
      })
    }))

    alert.addAction(UIAlertAction(title: Strings.no_forget_it(), style: .default, handler: { (action: UIAlertAction) in
      //TODO: Cancel Report
      completion(false)
    }))
    self.present(alert, animated: true, completion: nil)
  }

  private func showReportSuccessfullAlert(completion: @escaping ()->()) {
    let title = Strings.reported()
    let message = Strings.thank_you_for_report()
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.dismiss(), style: .default, handler: { (action: UIAlertAction) in
      //TODO: Send Report
    }))
    self.present(alert, animated: true, completion: nil)
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

extension UIViewController.MoreAction: Equatable {
  static func ==(lhs: UIViewController.MoreAction, rhs: UIViewController.MoreAction) -> Bool {
    switch (lhs, rhs) {
    case (let .report(type1), let .report(type2)):
      return type1 == type2
    }
  }
}
