//
//  SegmentedControlNode.swift
//  Bookwitty
//
//  Created by charles on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SegmentedControlNode: ASDisplayNode {
  private var segmentedControl: SegmentedControl!

  convenience override init() {
    self.init(viewBlock: { () -> UIView in
      let segmentedControl = SegmentedControl.instantiate()      
      return segmentedControl
    })

    self.segmentedControl = self.view as! SegmentedControl
  }

  func initialize(with segments: [String]) {
    self.segmentedControl.initialize(with: segments)
  }
}
