//
//  RichContentMenuViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RichContentMenuViewController: UIViewController {

  enum Item {
    case imageCamera
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    case imageLibrary
    case link
    case book
    case video
    case audio
    case quote
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
}
