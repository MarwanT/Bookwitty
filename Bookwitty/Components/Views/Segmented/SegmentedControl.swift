//
//  SegmentedControl.swift
//  Bookwitty
//
//  Created by charles on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Segmentio

typealias SegmentedControlSelectionCallBack = (_ segmentedControl: SegmentedControl, _ selectedSegmentIndex: Int) -> ()

final class SegmentedControl: UIView {
  private var segmentioView: Segmentio!
  private var segmentOtions: SegmentioOptions!

  var selectedSegmentChanged: SegmentedControlSelectionCallBack?

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

    segmentioView.valueDidChange = { (segmentio, selectedIndex) in
      self.selectedSegmentChanged?(self, selectedIndex)
    }

    let indicatorOptions = SegmentioIndicatorOptions(type: SegmentioIndicatorType.bottom,
                                                     ratio: 1.0,
                                                     height: 4.0,
                                                     color: ThemeManager.shared.currentTheme.defaultButtonColor())


    let horizontalSeparatorOptions = SegmentioHorizontalSeparatorOptions(type: SegmentioHorizontalSeparatorType.bottom,
                                                                         height: 2.0,
                                                                         color: ThemeManager.shared.currentTheme.defaultSeparatorColor())


    let defaultState = SegmentioState(backgroundColor: .clear,
                                      titleFont: FontDynamicType.footnote.font,
                                      titleTextColor: ThemeManager.shared.currentTheme.defaultGrayedTextColor())

    let selectedState = SegmentioState(backgroundColor: .clear,
                                       titleFont: FontDynamicType.footnote.font,
                                       titleTextColor: ThemeManager.shared.currentTheme.defaultTextColor())

    let highlightedState = SegmentioState(backgroundColor: .clear,
                                          titleFont: FontDynamicType.footnote.font,
                                          titleTextColor: ThemeManager.shared.currentTheme.defaultGrayedTextColor())

    let states = (defaultState, selectedState, highlightedState)

    segmentOtions = SegmentioOptions(backgroundColor: ThemeManager.shared.currentTheme.defaultBackgroundColor(),
                                     maxVisibleItems: 3,
                                     scrollEnabled: true,
                                     indicatorOptions: indicatorOptions,
                                     horizontalSeparatorOptions: horizontalSeparatorOptions,
                                     verticalSeparatorOptions: nil,
                                     imageContentMode: UIViewContentMode.scaleAspectFit,
                                     labelTextAlignment: NSTextAlignment.center,
                                     labelTextNumberOfLines: 1,
                                     segmentStates: states,
                                     animationDuration: 0.1)
  }

  func embed(in view: UIView) {
    guard !view.subviews.contains(self) else {
      return
    }

    view.addSubview(self)
    self.constrainHeight("45")
  }

  @discardableResult
  func initialize(with segments: [String]) -> Bool {
    guard segments.count > 0 else {
      return false
    }

    let segmentioSegments: [SegmentioItem] = segments.flatMap({ SegmentioItem(title: $0, image: nil) })
    let options = segmentOtions ?? SegmentioOptions()
    segmentioView.setup(content: segmentioSegments, style: SegmentioStyle.onlyLabel, options: options)
    segmentioView.selectedSegmentioIndex = 0
    return true
  }

  func select(index: Int) {
    segmentioView.selectedSegmentioIndex = index
  }
}
