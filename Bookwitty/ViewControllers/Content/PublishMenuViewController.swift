//
//  PublishMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol PublishMenuViewControllerDelegate: class {
  func publishMenu(_ viewController: PublishMenuViewController, didSelect item:PublishMenuViewController.Item)
}

class PublishMenuViewController: UIViewController {

  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var publishLabel: UILabel!
  enum Section: Int {
    case penName = 0
    case link
    case publish
  }
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
  
  weak var delegate: PublishMenuViewControllerDelegate?
  let viewModel = PublishMenuViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    // Do any additional setup after loading the view.
  }
  private func initializeComponents() {
    
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()

    let attributedString = AttributedStringBuilder(fontDynamicType: .caption1)
      .append(text: Strings.publish(), color: ThemeManager.shared.currentTheme.colorNumber13())
      .attributedString
    
    self.publishLabel.attributedText = attributedString
    self.tableView.register(UINib(nibName: "PublishTableViewCell", bundle: nil), forCellReuseIdentifier: RichMenuCellTableViewCell.identifier)
    self.tableView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableView.isScrollEnabled = false
    cancelButton.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableView.register(UINib(nibName: "PublishTableViewCell", bundle: nil), forCellReuseIdentifier: PublishTableViewCell.identifier)
    self.tableView.register(UINib(nibName: "ChipsTableViewCell", bundle: nil), forCellReuseIdentifier: ChipsTableViewCell.identifier)
    self.tableViewHeightConstraint.constant = tableView.contentSize.height
  }
}

extension PublishMenuViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfRows()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: PublishTableViewCell.identifier, for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    
    guard let currentCell = cell as? PublishTableViewCell else {
      return
    }
    currentCell.cellImageView.image = values.image
    currentCell.cellLabel.text = values.label
  }
}

extension PublishMenuViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return PublishTableViewCell.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let item = Item(rawValue: indexPath.row) else {
      return
    }
    
    self.delegate?.publishMenu(self, didSelect: item)
  }
}
