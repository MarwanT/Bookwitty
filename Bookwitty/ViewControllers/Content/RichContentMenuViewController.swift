//
//  RichContentMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol RichContentMenuViewControllerDelegate: class {
  func richContentMenuViewController(_ richContentMenuViewController: RichContentMenuViewController, didSelect:RichContentMenuViewController.Item)
  func richContentMenuViewControllerDidCancel(_ richContentMenuViewController: RichContentMenuViewController)
}

class RichContentMenuViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
  enum Item: Int {
    case imageCamera = 0
    case imageLibrary
    case link
    case book
    case video
    case audio
    case quote
    
    func localizedString() -> String {
      
      switch self {
      case .imageCamera:
        return Strings.imageFromCamera()
      case .imageLibrary:
        return Strings.imageFromPhotoLibrary()
      case .link:
        return Strings.link()
      case .book:
        return Strings.book()
      case .video:
        return Strings.video()
      case .audio:
        return Strings.audio()
      case .quote:
        return Strings.quote()
      }
    }
    
    func image() -> UIImage {
      
      switch self {
      case .imageCamera:
        return #imageLiteral(resourceName: "camera")
      case .imageLibrary:
        return #imageLiteral(resourceName: "gallery")
      case .link:
        return #imageLiteral(resourceName: "hyperlinkSmall")
      case .book:
        return #imageLiteral(resourceName: "books")
      case .video:
        return #imageLiteral(resourceName: "video")
      case .audio:
        return #imageLiteral(resourceName: "audio")
      case .quote:
        return #imageLiteral(resourceName: "quotes")
      }
    }
  }
  
  var tableViewCellHeight: CGFloat {
    return 45.0
  }
  weak var delegate: RichContentMenuViewControllerDelegate?
  
  let viewModel = RichContentMenuViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupTableView()
  }
  
  func setupTableView() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.register(UINib(nibName: "RichMenuCellTableViewCell", bundle: nil), forCellReuseIdentifier: RichMenuCellTableViewCell.identifier)
    self.tableView.tintColor = ThemeManager.shared.currentTheme.defaultTextColor()
    self.tableView.isScrollEnabled = false
    self.tableViewHeightContraint.constant = self.tableViewCellHeight * CGFloat(self.viewModel.numberOfRows()) + 49.0 // tabbar Height
  }
  
  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    self.delegate?.richContentMenuViewControllerDidCancel(self)
  }
}

extension RichContentMenuViewController : UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfRows()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: RichMenuCellTableViewCell.identifier, for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = self.viewModel.values(forRowAt: indexPath)
    
    guard let currentCell = cell as? RichMenuCellTableViewCell else {
      return
    }
    currentCell.menuImageView.image = values.image
    currentCell.menuLabel.text = values.label
  }
}


extension RichContentMenuViewController : UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tableViewCellHeight
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let item = Item(rawValue: indexPath.row) else {
      fatalError()
    }
    self.delegate?.richContentMenuViewController(self, didSelect: item)
  }
}
