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
  static let nodeHeight: CGFloat = 45.0
  let activityIndicatorNode: ASCellNode
  var loaderView: UIActivityIndicatorView? {
    return isNodeLoaded ? activityIndicatorNode.view as? UIActivityIndicatorView : nil
  }

  override init() {
    activityIndicatorNode = ASCellNode(viewBlock: { () -> UIView in
      let activityIndicatorView = UIActivityIndicatorView()
      activityIndicatorView.activityIndicatorViewStyle = .white
      activityIndicatorView.color = UIColor.bwRuby
      activityIndicatorView.hidesWhenStopped = true
      print(activityIndicatorView.frame.height)
      return activityIndicatorView
    })
    super.init()
    automaticallyManagesSubnodes = true
    style.height = ASDimensionMake(LoaderNode.nodeHeight)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY,
                              sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0),
                              child: activityIndicatorNode)
  }

  func updateLoaderVisibility(show: Bool) {
    style.height = ASDimensionMake(show ? LoaderNode.nodeHeight : 0.0)
    if show {
      loaderView?.startAnimating()
    } else {
      loaderView?.stopAnimating()
    }
    setNeedsLayout()
  }
}
