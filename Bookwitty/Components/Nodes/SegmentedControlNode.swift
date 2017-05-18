//
//  SegmentedControlNode.swift
//  Bookwitty
//
//  Created by charles on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

typealias SegmentedControlNodeSelectionCallBack = (_ segmentedControlNode: SegmentedControlNode, _ selectedSegmentIndex: Int) -> ()

class SegmentedControlNode: ASCellNode {
  private var segmentedControl: SegmentedControl!

  var selectedSegmentChanged: SegmentedControlNodeSelectionCallBack?

  var selectedIndex: Int {
    return self.segmentedControl.selectedIndex
  }

  override init() {
    super.init()
    
    self.setViewBlock({ () -> UIView in
      let segmentedControl = SegmentedControl.instantiate()      
      return segmentedControl
    })

    self.segmentedControl = self.view as! SegmentedControl
    self.segmentedControl.selectedSegmentChanged = { (segmentedControl, selectedSegmentIndex) in
      self.selectedSegmentChanged?(self, selectedSegmentIndex)
    }
  }

  func initialize(with segments: [String]) {
    self.segmentedControl.initialize(with: segments)
  }
}
