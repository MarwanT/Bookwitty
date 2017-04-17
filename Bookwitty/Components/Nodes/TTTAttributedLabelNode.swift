//
//  TTTAttributedLabelNode.swift
//  Bookwitty
//
//  Created by Marwan  on 4/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import TTTAttributedLabel

class TTTAttributedLabelNode: ASDisplayNode {
  var label: TTTAttributedLabel?
  
  convenience override init() {
    self.init(viewBlock: { () -> UIView in
      let tttLabel = TTTAttributedLabel(frame: CGRect.zero)
      return tttLabel
    })

    DispatchQueue.main.async {
      self.label = self.view as? TTTAttributedLabel
      self.label?.linkAttributes = self.linkAttributes
      self.label?.attributedText = self.attributedText
      self.label?.delegate = self.delegate
      self.label?.textAlignment = self.textAlignment
    }
    
    initializeNode()
  }
  
  func initializeNode() {
    // If preferred size is not specified there is a chance of a crash
    style.preferredSize = CGSize(width: 45, height: 45)
  }
  
  
  // MARK: - TTTAttributedLabel APIs
  
  open var linkAttributes: [AnyHashable : Any]! {
    didSet {
      label?.linkAttributes = linkAttributes
    }
  }
  
  @NSCopying open var attributedText: NSAttributedString! {
    didSet {
      label?.attributedText = attributedText
    }
  }
  
  var textAlignment: NSTextAlignment = .left {
    didSet {
      self.label?.textAlignment = self.textAlignment
    }
  }
  
  open func addLink(to url: URL!, with range: NSRange) -> TTTAttributedLabelLink! {
    return label?.addLink(to: url, with: range)
  }
  
  weak var delegate: TTTAttributedLabelDelegate! {
    didSet {
      label?.delegate = delegate
    }
  }
}
