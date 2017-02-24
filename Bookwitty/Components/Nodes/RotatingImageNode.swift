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
  private let imageSize: CGSize = CGSize(width: 45, height: 45)
  private var angle: CATransform3D {
    return CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0) // Rotation Transform 
  }

  private override init() {
    super.init()
  }

  convenience init(image: UIImage? = nil, size: CGSize? = nil) {
    self.init()
    self.image = image ?? #imageLiteral(resourceName: "downArrow")
    self.style.preferredSize = size ?? imageSize
  }
}
