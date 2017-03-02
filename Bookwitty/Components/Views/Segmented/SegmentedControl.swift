//
//  SegmentedControl.swift
//  Bookwitty
//
//  Created by charles on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Segmentio

final class SegmentedControl: UIView {
  private var segmentioView: Segmentio!
  class func instantiate() -> SegmentedControl {
    let segmentedControl = SegmentedControl(frame: CGRect.zero)
    segmentedControl.initializeComponents()
    return segmentedControl
  }

  private func initializeComponents() {
    segmentioView = Segmentio(frame: CGRect.zero)
    segmentioView.translatesAutoresizingMaskIntoConstraints = false
    segmentioView.clipsToBounds = true

    self.addSubview(segmentioView)
    segmentioView.alignTopEdge(withView: self, predicate: "0")
    segmentioView.alignLeadingEdge(withView: self, predicate: "0")
    segmentioView.alignTrailingEdge(withView: self, predicate: "0")
    segmentioView.alignBottomEdge(withView: self, predicate: "0")
  }
}
