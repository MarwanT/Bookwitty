//
//  RichContentMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol RichContentMenuViewControllerDelegate: class {
  func richContentMenuViewController(_ richContentMenuViewController: RichContentMenuViewController, didSelect item:RichContentMenuViewController.Item)
  func richContentMenuViewControllerDidCancel(_ richContentMenuViewController: RichContentMenuViewController)
}

class RichContentMenuViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
  @IBOutlet weak var insert: UILabel!
  @IBOutlet weak var cancel: UIButton!
  @IBOutlet weak var bottomHeaderSeparator: UIView!
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
        return Strings.image_from_camera()
      case .imageLibrary:
        return Strings.image_from_photo_library()
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
        return #imageLiteral(resourceName: "hyperlinkMedium")
      case .book:
        return #imageLiteral(resourceName: "book")
      case .video:
        return #imageLiteral(resourceName: "video")
      case .audio:
        return #imageLiteral(resourceName: "audio")
      case .quote:
        return #imageLiteral(resourceName: "quotes")
      }
    }
  }
  
  let height: CGFloat = 43.0
  
  weak var delegate: RichContentMenuViewControllerDelegate?
  
  let viewModel = RichContentMenuViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initializeComponents()
    addTapGesture()
  }
  
  private func addTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RichContentMenuViewController
      .backgroundTapped(_:)))
    self.view.isUserInteractionEnabled = true
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
    let theme = ThemeManager.shared.currentTheme
    
    let attributedString = AttributedStringBuilder(fontDynamicType: .subheadline)
      .append(text: Strings.insert(), color: theme.colorNumber13())
      .attributedString
    
    self.insert.attributedText = attributedString
    self.tableView.register(UINib(nibName: "RichMenuCellTableViewCell", bundle: nil), forCellReuseIdentifier: RichMenuCellTableViewCell.identifier)
    self.tableView.tintColor = theme.colorNumber20()
    self.tableView.isScrollEnabled = false
    self.tableViewHeightContraint.constant = self.height * CGFloat(self.viewModel.numberOfRows())
    self.tableView.separatorColor = theme.defaultSeparatorColor()
    self.tableView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 42, bottom: 0, right: 0)
    cancel.tintColor = theme.colorNumber20()
  }
  
  @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
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
    return self.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let item = Item(rawValue: indexPath.row) else {
      return
    }
    self.delegate?.richContentMenuViewController(self, didSelect: item)
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
}

extension RichContentMenuViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == self.view
  }
}

extension RichContentMenuViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    bottomHeaderSeparator.backgroundColor = theme.defaultSeparatorColor()
  }
}
