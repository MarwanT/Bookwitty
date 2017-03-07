//
//  RotatingImageNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class RotatingImageNode: ASImageNode {
  enum Direction {
    case up
    case down
    case left
    case right
  }

  private let imageSize: CGSize = CGSize(width: 45, height: 45)
  private var rotationTransform: CATransform3D {
    switch(currentDirection) {
    case .up: return CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
    case .down: return CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 0.0, 1.0)
    case .left : return CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
    case .right : return CATransform3DMakeRotation(-CGFloat(M_PI_2), 0.0, 0.0, 1.0)
    }
  }

  var currentDirection: Direction = .down
  
  private override init() {
    super.init()
  }

  convenience init(image: UIImage? = nil, size: CGSize? = nil, direction: Direction = .down) {
    self.init()
    self.image = image ?? #imageLiteral(resourceName: "downArrow")
    self.style.preferredSize = size ?? imageSize
    self.updateDirection(direction: direction, animated: false)
  }

  func transformRotation(direction: Direction) -> CATransform3D {
    self.currentDirection = direction
    return self.rotationTransform
  }

  func updateDirection(direction: Direction, animated: Bool = true) {
    self.currentDirection = direction

    if animated {
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    } else {
      transform = self.rotationTransform
      setNeedsLayout()
    }
  }

  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    UIView.animate(withDuration: 0.4, animations: {
      self.transform = self.rotationTransform
    }) { (success) in
      context.completeTransition(success)
    }
  }
}
