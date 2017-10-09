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
    case preview
    case publish
    
    static let numberOfSections: Int = 4
  }
  enum Item {
    case penName
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
    self.tableView.register(UINib(nibName: "PublishTableViewCell", bundle: nil), forCellReuseIdentifier: PublishTableViewCell.identifier)
    self.tableView.register(UINib(nibName: "ChipsTableViewCell", bundle: nil), forCellReuseIdentifier: ChipsTableViewCell.identifier)
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()

    let attributedString = AttributedStringBuilder(fontDynamicType: .caption1)
      .append(text: Strings.publish(), color: ThemeManager.shared.currentTheme.colorNumber13())
      .attributedString
    
    self.publishLabel.attributedText = attributedString
    self.tableView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableView.isScrollEnabled = false
    cancelButton.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableViewHeightConstraint.constant = tableView.contentSize.height
  }
}

extension PublishMenuViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.viewModel.numberOfSections()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (Section.publish.rawValue, _):
      return tableView.dequeueReusableCell(withIdentifier: "PublishCellReuseIdentifier", for: indexPath)
    case (Section.link.rawValue, 0) where viewModel.tags.count > 0:
      fallthrough
    case (Section.link.rawValue, 1) where viewModel.links.count > 0:
      return tableView.dequeueReusableCell(withIdentifier: ChipsTableViewCell.identifier, for: indexPath)
    default:
      return tableView.dequeueReusableCell(withIdentifier: PublishTableViewCell.identifier, for: indexPath)
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    
    if let currentCell = cell as? PublishTableViewCell  {
      currentCell.cellImageView.image = values.label.image
      currentCell.cellLabel.text = values.label.title
    } else if let currentCell = cell as? ChipsTableViewCell  {
      currentCell.cellImageView.image = values.label.image
      currentCell.setTags(["a","b"])//.text = values.label.title
    } else {
      //From storyboard
      cell.textLabel?.text = values.label.title
      if indexPath.row == 0 {
        cell.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber19()
        cell.textLabel?.backgroundColor = ThemeManager.shared.currentTheme.colorNumber19()
        cell.textLabel?.textColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
      }
      cell.textLabel?.font = FontDynamicType.caption1.font
    }
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
