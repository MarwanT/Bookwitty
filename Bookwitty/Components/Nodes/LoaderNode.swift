//
//  LoaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LoaderNode: ASCellNode {
  static let defaultNodeHeight: CGFloat = 45.0
  let activityIndicatorNode: ASCellNode

  var usedHeight: CGFloat {
    return nodeHeight ?? LoaderNode.defaultNodeHeight
  }
  var loaderView: UIActivityIndicatorView? {
    return isNodeLoaded ? activityIndicatorNode.view as? UIActivityIndicatorView : nil
  }
  private var nodeHeight: CGFloat?

  override init() {
    activityIndicatorNode = ASCellNode(viewBlock: { () -> UIView in
      let activityIndicatorView = UIActivityIndicatorView()
      activityIndicatorView.activityIndicatorViewStyle = .white
      activityIndicatorView.color = UIColor.bwRuby
      activityIndicatorView.hidesWhenStopped = true
      activityIndicatorView.backgroundColor = UIColor.clear
      return activityIndicatorView
    })
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  convenience init(nodeHeight: CGFloat) {
    self.init()
    self.nodeHeight = nodeHeight
    initializeNode()
  }

  func initializeNode() {
    style.height = ASDimensionMake(usedHeight)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY,
                              sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0),
                              child: activityIndicatorNode)
  }

  func updateLoaderVisibility(show: Bool) {
    style.height = ASDimensionMake(show ? LoaderNode.defaultNodeHeight : 0.0)
    isHidden = !show
    if show {
      loaderView?.startAnimating()
    } else {
      loaderView?.stopAnimating()
    }
    setNeedsLayout()
  }
}
