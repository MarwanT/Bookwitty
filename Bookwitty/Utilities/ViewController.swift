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
    case modify(edit: Bool, delete: Bool)
    case report(ReportType)

    static func actions(for resource: ModelCommonProperties?) -> [MoreAction] {
      guard let resource = resource else {
        return []
      }

      var actions: [MoreAction] = []
      if let penName = resource as? PenName {
        if !UserManager.shared.isMyDefault(penName: penName) {
          actions.append(.report(.penName))
        }
      }

      if let penName = resource.penName {
        let mine = UserManager.shared.isMyDefault(penName: penName)
        let editable = mine && (resource is CandidatePost)

        if mine {
          actions.append(.modify(edit: editable, delete: mine))
        } else {
          actions.append(.report(.content))
        }
      }
      return actions
    }
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
    guard let resource = resource else {
      return
    }

    let commentsVC = CommentsViewController()
    commentsVC.initialize(with: resource)
    commentsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(commentsVC, animated: true)
  }

  func showMoreActionSheet(identifier: String, actions: [MoreAction], completion: @escaping (_ success: Bool, _ action: MoreAction)->()) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)


    //Check if .modify is in the actions
    let modifyIndex: Int? = actions.index(where: {
      if case .modify = $0 {
        return true
      }
      return false
    })

    if let index = modifyIndex {
      if case let MoreAction.modify(edit, delete) = actions[index] {
        if edit {
          guard let post = DataManager.shared.fetchResource(with: identifier) as? CandidatePost else {
            completion(false, .modify(edit: true, delete: false))
            return
          }

          alert.addAction(UIAlertAction(title: Strings.edit(), style: .default, handler: { (action: UIAlertAction) in
            self.presentContentEditor(with: post)
            completion(true, .modify(edit: true, delete: false))
          }))
        }

        if delete {
          alert.addAction(UIAlertAction(title: Strings.delete(), style: .destructive, handler: { (action: UIAlertAction) in
            self.showDeleteConfirmationAlert(identifier: identifier, completion: { (success: Bool) in
              completion(success, .modify(edit: false, delete: true))
            })
          }))
        }
      }
    }

    if actions.contains(where: { $0 == .report(.content) }) {
      alert.addAction(UIAlertAction(title: Strings.report(), style: .destructive, handler: { (action: UIAlertAction) in
        self.showReportContentAlert(identifier: identifier, completion: { (success: Bool) in
          completion(success, .report(.content))
        })
      }))
    }

    if actions.contains(where: { $0 == .report(.penName) }) {
      alert.addAction(UIAlertAction(title: Strings.report(), style: .destructive, handler: { (action: UIAlertAction) in
        self.showReportPenNameAlert(identifier: identifier, completion: { (success: Bool) in
          completion(success, .report(.penName))
        })
      }))
    }

    alert.addAction(UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func showDeleteConfirmationAlert(identifier: String, completion: @escaping (_ success: Bool)->()) {
    //TODO: Localize
    let message = "Are you sure you want to delete this post ?"
    let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction) in
      _ = PublishAPI.removeContent(contentIdentifier: identifier, completion: { (success: Bool, error: BookwittyAPIError?) in
        if success {
          DataManager.shared.deleteResource(with: identifier)
          self.showDeleteContentSuccessfullAlert(completion: { 
            completion(success)
          })
        }
      })
    }))

    //TODO: Localize
    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction) in
      completion(false)
    }))
    self.present(alert, animated: true, completion: nil)
  }

  func showReportPenNameAlert(identifier: String, completion: @escaping (_ success: Bool)->()) {
    let title = Strings.report()
    let message = Strings.report_this_content()
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.yes_this_is_spam(), style: .destructive, handler: { (action: UIAlertAction) in
      _ = PenNameAPI.report(identifier: identifier, completion: { (success: Bool, error: BookwittyAPIError?) in
        if success {
          DataManager.shared.updateResource(with: identifier, after: .report)
          self.showReportSuccessfullAlert(completion: {
            completion(success)
          })
        }
      })

      //MARK: [Analytics] Event
      guard let resource = DataManager.shared.fetchResource(with: identifier) as? PenName else {
        return
      }

      var name: String = resource.name ?? ""
      let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                   action: .ConfirmReport,
                                                   name: name)
      Analytics.shared.send(event: event)
    }))

    alert.addAction(UIAlertAction(title: Strings.no_forget_it(), style: .default, handler: { (action: UIAlertAction) in
      completion(false)
    }))
    self.present(alert, animated: true, completion: nil)
  }

  func showReportContentAlert(identifier: String, completion: @escaping (_ success: Bool)->()) {
    let title = Strings.report()
    let message = Strings.report_this_content()
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.yes_this_is_spam(), style: .destructive, handler: { (action: UIAlertAction) in
      _ = ContentAPI.report(identifier: identifier, completion: { (success: Bool, error: BookwittyAPIError?) in
        if success {
          DataManager.shared.updateResource(with: identifier, after: .report)
          self.showReportSuccessfullAlert(completion: {
            completion(success)
          })
        }
      })

      //MARK: [Analytics] Event
      guard let resource = DataManager.shared.fetchResource(with: identifier) as? ModelCommonProperties else {
        return
      }

      let category: Analytics.Category
      var name: String = resource.title ?? ""
      switch resource.registeredResourceType {
      case Image.resourceType:
        category = .Image
      case Quote.resourceType:
        category = .Quote
      case Video.resourceType:
        category = .Video
      case Audio.resourceType:
        category = .Audio
      case Link.resourceType:
        category = .Link
      case Author.resourceType:
        category = .Author
        name = (resource as? Author)?.name ?? ""
      case ReadingList.resourceType:
        category = .ReadingList
      case Topic.resourceType:
        category = .Topic
      case Text.resourceType:
        category = .Text
      case Book.resourceType:
        category = .TopicBook
      case PenName.resourceType:
        category = .PenName
        name = (resource as? PenName)?.name ?? ""
      default:
        category = .Default
      }

      let event: Analytics.Event = Analytics.Event(category: category,
                                                   action: .ConfirmReport,
                                                   name: name)
      Analytics.shared.send(event: event)
    }))

    alert.addAction(UIAlertAction(title: Strings.no_forget_it(), style: .default, handler: { (action: UIAlertAction) in
      completion(false)
    }))
    self.present(alert, animated: true, completion: nil)
  }

  private func showReportSuccessfullAlert(completion: @escaping ()->()) {
    let title = Strings.reported()
    let message = Strings.thank_you_for_report()
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.dismiss(), style: .default, handler: { (action: UIAlertAction) in
      completion()
    }))
    self.present(alert, animated: true, completion: nil)
  }

  private func showDeleteContentSuccessfullAlert(completion: @escaping ()->()) {
    //TODO: Localize
    let title = "deleted"
    let message = "Your post has been deleted"
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
      completion()
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

extension UIViewController {
  func presentContentEditor(with post: CandidatePost, prelink: String? = nil) {
    let editorController = Storyboard.Content.instantiate(ContentEditorViewController.self)
    editorController.viewModel.initialize(with: post, prelink: prelink)
    let navigationController = UINavigationController(rootViewController: editorController)
    self.present(navigationController, animated: true, completion: nil)
  }
}

extension UIViewController.MoreAction: Equatable {
  static func ==(lhs: UIViewController.MoreAction, rhs: UIViewController.MoreAction) -> Bool {
    switch (lhs, rhs) {
    case (let .report(type1), let .report(type2)):
      return type1 == type2
    case (let .modify(edit1, delete1), let .modify(edit2, delete2)):
      return edit1 == edit2 && delete1 == delete2
    default:
      return false
    }
  }
}
