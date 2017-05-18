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
  fileprivate var activityIndicatorView: UIActivityIndicatorView!

  private var nodeHeight: CGFloat?
  
  override init() {
    super.init()
    
    self.setViewBlock { () -> UIView in
      let activityIndicatorView = UIActivityIndicatorView()
      activityIndicatorView.activityIndicatorViewStyle = .white
      activityIndicatorView.color = UIColor.bwRuby
      activityIndicatorView.hidesWhenStopped = true
      activityIndicatorView.backgroundColor = UIColor.clear
      return activityIndicatorView
    }
    
    DispatchQueue.main.async {
      self.activityIndicatorView = self.view as! UIActivityIndicatorView
    }
    initializeNode()
  }

  func initializeNode() {
    style.preferredSize = CGSize(width: LoaderNode.defaultNodeHeight, height: LoaderNode.defaultNodeHeight)
  }

  func updateLoaderVisibility(show: Bool) {
    isHidden = !show
    if show {
      activityIndicatorView?.startAnimating()
    } else {
      activityIndicatorView?.stopAnimating()
    }
    setNeedsLayout()
  }
}
