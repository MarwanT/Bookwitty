//
//  SegmentedControl.swift
//  Bookwitty
//
//  Created by charles on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

final class SegmentedControl: UIView {
  class func instantiate() -> SegmentedControl {
    let segmentedControl = SegmentedControl(frame: CGRect.zero)
    segmentedControl.initializeComponents()
    return segmentedControl
  }

  private func initializeComponents() {

  }
}
