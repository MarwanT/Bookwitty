//
//  NewsCollectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CellNode: ASCellNode {
  var label: ASTextNode

  override init() {
    label = ASTextNode()
    super.init()

    backgroundColor = UIColor.bwCupid

    label.attributedText = AttributedStringBuilder.init(fontDynamicType: .title1).append(text: "Test").attributedString
    addSubnode(label)
  }

  var text: String {
    get {
      return label.attributedText?.string ?? ""
    }
    set {
      label.attributedText = AttributedStringBuilder.init(fontDynamicType: .title1).append(text: newValue).attributedString
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: label)
  }

}
