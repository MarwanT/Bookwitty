//
//  RichContentMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

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
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
}
