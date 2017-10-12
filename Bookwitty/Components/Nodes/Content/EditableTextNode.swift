//
//  EditableTextNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/09.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class EditableTextNode: ASCellNode {
  let textNode: ASEditableTextNode
  let clearButtonNode: ASButtonNode

  override init() {
    textNode = ASEditableTextNode()
    clearButtonNode = ASButtonNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    textNode.style.height = ASDimension(unit: .points, value: 80.0)
    textNode.maximumLinesToDisplay = 2

    textNode.style.flexGrow = 1.0
    textNode.style.flexShrink = 1.0

    clearButtonNode.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    clearButtonNode.imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    clearButtonNode.setImage(#imageLiteral(resourceName: "x"), for: .normal)

    clearButtonNode.addTarget(self, action: #selector(clearButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  override func didLoad() {
    super.didLoad()
    applyTheme()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let nodesArray: [ASLayoutElement] = [textNode, clearButtonNode]
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                         spacing: 0.0,
                                         justifyContent: .start,
                                         alignItems: .center,
                                         children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: externalEdgeInsets(), child: horizontalSpec)
    return insetSpec
  }

  private func externalEdgeInsets() -> UIEdgeInsets {
    return UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }

  @objc fileprivate func clearButtonTouchUpInside(_ sender: ASButtonNode) {
    //TODO: Empty impementation
  }
}

extension EditableTextNode: Themeable {
  func applyTheme() {
    textNode.textView.font = FontDynamicType.title2.font
    textNode.textView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}
