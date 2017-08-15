//
//  TagCollectionNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/15.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TagCollectionNode: ASCellNode {
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)

  fileprivate var tags: [String]

  let imageNode: ASImageNode
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  override init() {
    tags = []
    imageNode = ASImageNode()
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init()
    setupNode()
  }

  private func setupNode() {
    automaticallyManagesSubnodes = true

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode.dataSource = self
    collectionNode.delegate = self
    
    collectionNode.style.flexGrow = 1.0

    imageNode.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    imageNode.style.preferredSize = imageSize
    imageNode.image = #imageLiteral(resourceName: "tag")

    style.flexGrow = 1.0
    style.flexShrink = 1.0
  }

  override func didLoad() {
    super.didLoad()
    collectionNode.view.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "contentSize" {
      guard let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize else {
        return
      }

      if newSize != collectionNode.style.preferredSize {
        collectionNode.style.preferredSize = newSize
        collectionNode.setNeedsLayout()
      }
    }
  }

  func set(tags: [String]) {
    self.tags.removeAll()
    self.tags += tags
    collectionNode.reloadData()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    collectionNode.style.maxWidth = ASDimensionMakeWithFraction(0.8)
    return ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .start, children: [imageNode, collectionNode])
  }
}

extension TagCollectionNode: ASCollectionDataSource, ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return tags.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let tagValue: String = tags[indexPath.item]
    return  {
      let tagNode = TagNode()
      tagNode.tag = tagValue
      return tagNode
    }
  }
}
