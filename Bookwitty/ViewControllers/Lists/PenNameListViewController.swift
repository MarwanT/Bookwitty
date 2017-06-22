//
//  PenNameListViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameListViewController: ASViewController<ASCollectionNode> {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.PenNameList)
  }
}
