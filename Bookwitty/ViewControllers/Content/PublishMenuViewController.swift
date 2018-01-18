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
  @IBOutlet weak var bottomHeaderSeparator: UIView!
  
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
        return #imageLiteral(resourceName: "linkTopic")
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
    applyTheme()
    initializeComponents()
    // Do any additional setup after loading the view.
    addTapGesture()
  }
  
  private func addTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PublishMenuViewController.backgroundTapped(_:)))
    tapGesture.delegate = self
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    self.view.addGestureRecognizer(tapGesture)
  }
  
  func backgroundTapped(_ sender:UIGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let when = DispatchTime.now() + 0.2
    DispatchQueue.main.asyncAfter(deadline: when) {
      UIView.animate(withDuration: 0.250) {
        self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber20().withAlphaComponent(0.5)
        
      }
    }
  }
  
  private func initializeComponents() {
    self.tableView.register(UINib(nibName: "PublishTableViewCell", bundle: nil), forCellReuseIdentifier: PublishTableViewCell.identifier)
    self.tableView.register(UINib(nibName: "ChipsTableViewCell", bundle: nil), forCellReuseIdentifier: ChipsTableViewCell.identifier)
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()
    
    self.publishLabel.text = Strings.publish()
    self.tableView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableView.isScrollEnabled = false
    self.tableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    cancelButton.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    self.tableViewHeightConstraint.constant = tableView.contentSize.height
  }
  @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
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
    case (Section.link.rawValue, 0) where viewModel.getTags.count > 0:
      fallthrough
    case (Section.link.rawValue, 1) where viewModel.getTopics.count > 0:
      return tableView.dequeueReusableCell(withIdentifier: ChipsTableViewCell.identifier, for: indexPath)
    default:
      return tableView.dequeueReusableCell(withIdentifier: PublishTableViewCell.identifier, for: indexPath)
    }
  }
  
  func willDisplayPenName(_ cell: UITableViewCell, at indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    guard let currentCell = cell as? PublishTableViewCell else {
      return
    }
    currentCell.cellImageView.image = values.label.image
    currentCell.cellLabel.text = values.label.title
    currentCell.userNameLabel.text = UserManager.shared.defaultPenName?.name
    currentCell.userNameLabel.textColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    currentCell.userNameLabel.isHidden = false
    currentCell.profileImageView.isHidden = false
    currentCell.disclosureIndicatorImageView.isHidden = false
    if let avatar = UserManager.shared.defaultPenName?.avatarUrl, let imageURL = URL(string: avatar) {
      currentCell.profileImageView.sd_setImage(with: imageURL, placeholderImage: ThemeManager.shared.currentTheme.penNamePlaceholder)
    } else {
      currentCell.profileImageView.image = ThemeManager.shared.currentTheme.penNamePlaceholder
    }
  }
  
  func willDisplayLink(_ cell: UITableViewCell, at indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    let row = indexPath.row
    
    if row == 0 {
      if viewModel.getTags.count > 0 {
        guard let currentCell = cell as? ChipsTableViewCell else {
          return
        }
        currentCell.cellImageView.image = values.label.image
        currentCell.setTags(self.viewModel.getTags.flatMap { $0.title })
      } else {
        guard let currentCell = cell as? PublishTableViewCell else {
          return
        }
        currentCell.cellImageView.image = values.label.image
        currentCell.cellLabel.text = values.label.title
      }
      
    } else if row == 1 {
      
      if viewModel.getTopics.count > 0 {
        guard let currentCell = cell as? ChipsTableViewCell else {
          return
        }
        currentCell.cellImageView.image = values.label.image
        currentCell.setTags(self.viewModel.getTopics.flatMap { $0.title })
      } else {
        guard let currentCell = cell as? PublishTableViewCell else {
          return
        }
        currentCell.cellImageView.image = values.label.image
        currentCell.cellLabel.text = values.label.title
      }
    }
  }
  
  func willDisplayPublish(_ cell: UITableViewCell, at indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    //From storyboard
    cell.textLabel?.text = values.label.title
    if indexPath.row == 0 {
      cell.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber19()
      cell.textLabel?.backgroundColor = ThemeManager.shared.currentTheme.colorNumber19()
      cell.textLabel?.textColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    }
    cell.textLabel?.font = FontDynamicType.caption1.font
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    
    guard let section = Section(rawValue: indexPath.section) else {
      return
    }
    switch section {
    case .penName:
      self.willDisplayPenName(cell, at: indexPath)
    case .link:
      self.willDisplayLink(cell, at: indexPath)
    case .preview:
      guard let currentCell = cell as? PublishTableViewCell else {
        return
      }
      currentCell.cellImageView.image = values.label.image
      currentCell.cellLabel.text = values.label.title
    case .publish:
      self.willDisplayPublish(cell, at: indexPath)
    }
  }
}

extension PublishMenuViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == Section.link.rawValue {
      return (tableView.cellForRow(at: indexPath) as? ChipsTableViewCell)?.tagsView.bounds.height ?? 44.0
    }
    return PublishTableViewCell.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let item = Item.value(for: indexPath) else {
      return
    }
    
    self.delegate?.publishMenu(self, didSelect: item)
  }
}

extension PublishMenuViewController.Item {
  
  static func value(for indexPath: IndexPath) -> PublishMenuViewController.Item?  {
    switch (indexPath.section, indexPath.row) {
    case (PublishMenuViewController.Section.penName.rawValue, _):
      return .penName
    case (PublishMenuViewController.Section.link.rawValue, let row) where row == 0:
      return .addTags
    case (PublishMenuViewController.Section.link.rawValue, let row) where row == 1:
      return .linkTopics
    case (PublishMenuViewController.Section.preview.rawValue, _):
      return .postPreview
    case (PublishMenuViewController.Section.publish.rawValue, let row) where row == 0:
      return .publishYourPost
    case (PublishMenuViewController.Section.publish.rawValue, let row) where row == 1:
      return .saveAsDraft
    case (PublishMenuViewController.Section.publish.rawValue, let row) where row == 2:
      return .goBack
    default:
      return nil
    }
  }
}

extension PublishMenuViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == self.view
  }
}

extension PublishMenuViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    publishLabel.textColor = theme.colorNumber13()
    publishLabel.font = FontDynamicType.subheadline.font
    bottomHeaderSeparator.backgroundColor = theme.defaultSeparatorColor()
  }
}
