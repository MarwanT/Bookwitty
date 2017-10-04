//
//  PublishMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PublishMenuViewController: UIViewController {

  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var publishLabel: UILabel!
  enum Item: Int {
    case penName = 0
    case linkTopics
    case addTags
    case postPreview
    case publishYourPost
    case saveAsDraft
    case goBack
    
    var localizedString: String {
      switch self {
      case .penName:
        return Strings.pen_name()
      case .linkTopics:
        return Strings.link_topics()
      case .addTags:
        return Strings.add_tags()
      case .postPreview:
        return Strings.post_preview()
      case .publishYourPost:
        return Strings.publish_your_post()
      case .saveAsDraft:
        return Strings.save_as_draft()
      case .goBack:
        return Strings.go_back()
      }
    }
    
    var image: UIImage? {
      switch self {
      case .penName:
        return #imageLiteral(resourceName: "person")
      case .linkTopics:
        return nil
      case .addTags:
        return #imageLiteral(resourceName: "tag")
      case .postPreview:
        return #imageLiteral(resourceName: "gallery")
      case .publishYourPost:
        return nil
      case .saveAsDraft:
        return nil
      case .goBack:
        return nil
      }
    }
  }
  
  let viewModel = PublishMenuViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    // Do any additional setup after loading the view.
  }
  private func initializeComponents() {
    
    let attributedString = AttributedStringBuilder(fontDynamicType: .caption1)
      .append(text: Strings.publish(), color: ThemeManager.shared.currentTheme.colorNumber13())
      .attributedString
    
    self.publishLabel.attributedText = attributedString
    self.tableView.register(UINib(nibName: "PublishTableViewCell", bundle: nil), forCellReuseIdentifier: RichMenuCellTableViewCell.identifier)
    self.tableView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableView.isScrollEnabled = false
    self.tableViewHeightConstraint.constant = PublishTableViewCell.height * CGFloat(self.viewModel.numberOfRows())
    publishLabel.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
  }
}
