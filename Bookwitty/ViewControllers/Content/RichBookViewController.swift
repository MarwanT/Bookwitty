//
//  RichBookViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class RichBookViewController: ASViewController<ASCollectionNode> {

  var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()

      searchBar?.becomeFirstResponder()
    }
}
