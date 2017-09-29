//
//  UIView+Autolayout.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension UIView {
  
  /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
  func bindFrameToSuperviewBounds() {
    guard let superview = self.superview else {
      fatalError("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
    }
    
    self.translatesAutoresizingMaskIntoConstraints = false
    superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
  }

  func addAutoLayoutSubview(_ subview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subview)
  }
  
  @discardableResult
  public func addParentLeadingConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: view,
      attribute: NSLayoutAttribute.leading,
      relatedBy: NSLayoutRelation.equal,
      toItem: self,
      attribute: NSLayoutAttribute.leading,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addParentTrailingConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: NSLayoutAttribute.trailing,
      relatedBy: NSLayoutRelation.equal,
      toItem: view,
      attribute: NSLayoutAttribute.trailing,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addParentTopConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: view,
      attribute: NSLayoutAttribute.top,
      relatedBy: NSLayoutRelation.equal,
      toItem: self,
      attribute: NSLayoutAttribute.top,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addParentBottomConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: NSLayoutAttribute.bottom,
      relatedBy: NSLayoutRelation.equal,
      toItem: view,
      attribute: NSLayoutAttribute.bottom,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addParentCenterXConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: view,
      attribute: NSLayoutAttribute.centerX,
      relatedBy: NSLayoutRelation.equal,
      toItem: self,
      attribute: NSLayoutAttribute.centerX,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addParentCenterYConstraint(_ view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: view,
      attribute: NSLayoutAttribute.centerY,
      relatedBy: NSLayoutRelation.equal,
      toItem: self,
      attribute: NSLayoutAttribute.centerY,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addHeightConstraint(_ value: CGFloat) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: NSLayoutAttribute.height,
      relatedBy: NSLayoutRelation.equal,
      toItem: nil,
      attribute: NSLayoutAttribute.notAnAttribute,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addWidthConstraint(_ value: CGFloat) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: NSLayoutAttribute.width,
      relatedBy: NSLayoutRelation.equal,
      toItem: nil,
      attribute: NSLayoutAttribute.notAnAttribute,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func pinParentHorizontal(_ view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array.append(addParentLeadingConstraint(view, value: leadingValue))
    array.append(addParentTrailingConstraint(view, value: trailingValue))
    return array
  }
  
  @discardableResult
  public func pinParentVertical(_ view: UIView, topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array.append(addParentTopConstraint(view, value: topValue))
    array.append(addParentBottomConstraint(view, value: bottomValue))
    return array
  }
  
  @discardableResult
  public func pinParentAllDirections(_ view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0,
                                     topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array += pinParentHorizontal(view, leadingValue: leadingValue, trailingValue: trailingValue)
    array += pinParentVertical(view, topValue: topValue, bottomValue: bottomValue)
    return array
  }
  
  @discardableResult
  public func addParentCenter(_ view: UIView, centerX: CGFloat = 0, centerY: CGFloat = 0) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array.append(addParentCenterXConstraint(view, value: centerX))
    array.append(addParentCenterYConstraint(view, value: centerY))
    return array
  }
  
  @discardableResult
  public func addSiblingHorizontalContiguous(left: UIView, right: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: right,
      attribute: NSLayoutAttribute.leading,
      relatedBy: NSLayoutRelation.equal,
      toItem: left,
      attribute: NSLayoutAttribute.trailing,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addSiblingVerticalContiguous(top: UIView, bottom: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: bottom,
      attribute: NSLayoutAttribute.top,
      relatedBy: NSLayoutRelation.equal,
      toItem: top,
      attribute: NSLayoutAttribute.bottom,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func alignSiblingTop(first: UIView, second: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: first,
      attribute: NSLayoutAttribute.top,
      relatedBy: NSLayoutRelation.equal,
      toItem: second,
      attribute: NSLayoutAttribute.top,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func alignSiblingBottom(first: UIView, second: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: first,
      attribute: NSLayoutAttribute.bottom,
      relatedBy: NSLayoutRelation.equal,
      toItem: second,
      attribute: NSLayoutAttribute.bottom,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func alignSiblingLeading(first: UIView, second: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: first,
      attribute: NSLayoutAttribute.leading,
      relatedBy: NSLayoutRelation.equal,
      toItem: second,
      attribute: NSLayoutAttribute.leading,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func alignSiblingTrailing(first: UIView, second: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: first,
      attribute: NSLayoutAttribute.trailing,
      relatedBy: NSLayoutRelation.equal,
      toItem: second,
      attribute: NSLayoutAttribute.trailing,
      multiplier: 1,
      constant: value)
    addConstraint(constraint)
    return constraint
  }
  
  @discardableResult
  public func addEqualWidth(views: [UIView], value: CGFloat = 0) -> [NSLayoutConstraint] {
    
    assert(views.count > 1, "should have at least 2 views")
    
    let view1 = views[0]
    var constraints = [NSLayoutConstraint]()
    for i in 1..<views.count {
      let view2 = views[i]
      let constraint = NSLayoutConstraint(
        item: view1,
        attribute: NSLayoutAttribute.width,
        relatedBy: NSLayoutRelation.equal,
        toItem: view2,
        attribute: NSLayoutAttribute.width,
        multiplier: 1,
        constant: value)
      constraints.append(constraint)
      addConstraint(constraint)
    }
    
    return constraints
  }
  
  @discardableResult
  public func addEqualHeight(views: [UIView], value: CGFloat = 0) -> [NSLayoutConstraint] {
    
    assert(views.count > 1, "should have at least 2 views")
    
    let view1 = views[0]
    var constraints = [NSLayoutConstraint]()
    for i in 1..<views.count {
      let view2 = views[i]
      let constraint = NSLayoutConstraint(
        item: view1,
        attribute: NSLayoutAttribute.height,
        relatedBy: NSLayoutRelation.equal,
        toItem: view2,
        attribute: NSLayoutAttribute.height,
        multiplier: 1,
        constant: value)
      constraints.append(constraint)
      addConstraint(constraint)
    }
    
    return constraints
  }
  
  @discardableResult
  public func addEqualSize(views: [UIView], width: CGFloat = 0, height: CGFloat = 0) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array.append(contentsOf: addEqualHeight(views: views, value: height))
    array.append(contentsOf: addEqualWidth(views: views, value: width))
    return array
  }
  
  @discardableResult
  public func addSizeConstraints(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
    var array: [NSLayoutConstraint] = []
    array.append(addWidthConstraint(width))
    array.append(addHeightConstraint(height))
    return array
  }
}
