//
//  Node+Util.swift
//  Bookwitty
//
//  Created by Marwan  on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

extension ASDisplayNode {
  func viewController(title: String? = nil) -> UIViewController {
    let genericViewController = GenericNodeViewController(node: self, title: title, scrollableContentIfNeeded: false)
    return genericViewController
  }
}
