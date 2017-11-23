//
//  HighlightNode.swift
//  Bookwitty
//
//  Created by Marwan  on 11/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class HighlightNode: ASDisplayNode {
  var highlightColor: UIColor = ThemeManager.shared.currentTheme.colorNumber2() {
    didSet {
      backgroundColor = highlightColor
    }
  }
  var coolDownColor: UIColor = UIColor.white
  var animationDuration: TimeInterval = 0.60
  
  fileprivate var didFinishCoolDown: (() -> Void)?
  
  override init() {
    super.init()
    backgroundColor = highlightColor
  }
  
  func startCoolDown(completion: (() -> Void)?) {
    didFinishCoolDown = completion
    transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    UIView.animate(withDuration: animationDuration, animations: {
      self.backgroundColor = self.coolDownColor
    }) { (success) in
      context.completeTransition(true)
      self.removeFromSupernode()
      self.didFinishCoolDown?()
    }
  }
}
