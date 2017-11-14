//
//  DynamicCommentMessageNode.swift
//  Bookwitty
//
//  Created by Marwan  on 11/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText
import Foundation

class DynamicCommentMessageNode: ASCellNode {
  // MARK: - Subviews
  //=================
  var textContentView: DTAttributedLabel?
  
  // MARK: Layout Variables
  //=======================
  fileprivate let layouter = DTCoreTextLayouter()
  var configuration = Configuration() {
    didSet {
      refreshNode()
    }
  }
  var mode: DynamicMode = .collapsed {
    didSet {
      refreshNode()
    }
  }
  var numberOfWits: Int? {
    didSet {
      refreshNode()
    }
  }
  
  // MARK: Content Variables
  //========================
  private var originalAttributedString: NSAttributedString? {
    didSet {
      layouter.attributedString = currentAttributedString()
      textContentView?.attributedString = currentAttributedString()
    }
  }
  
  // MARK: - Lifecycle
  //==================
  override convenience init() {
    self.init(viewBlock: { () -> UIView in
      let textContentView = DTAttributedLabel()
      textContentView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
      return textContentView
    })
    style.maxHeight = ASDimensionMake(10000)
  }
  
  override func didLoad() {
    super.didLoad()
    self.textContentView = self.view as? DTAttributedLabel
    self.textContentView?.delegate = self
    self.textContentView?.lineBreakMode = .byTruncatingTail
    self.textContentView?.truncationString = self.configuration.truncationString
    self.textContentView?.attributedString = currentAttributedString()
    self.textContentView?.numberOfLines = self.configuration.numberOfLines
  }
  
  // MARK: Layout
  //=============
  override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
    return preferredLayoutSize(for: constrainedSize) ?? constrainedSize
  }
  
  fileprivate func refreshNode() {
    self.textContentView?.numberOfLines = self.configuration.numberOfLines
    self.textContentView?.attributedString = currentAttributedString()
  }
  
  /// Generates the string to be displayed based on the current context
  fileprivate func currentAttributedString() -> NSAttributedString? {
    //TODO: Form the displayed attributed text
    return originalAttributedString
  }
  
  // MARK: APIs
  //===========
  func htmlString(text: String?, fontDynamicType: FontDynamicType? = nil,
                  color: UIColor? = nil) {
    guard let text = text else {
      originalAttributedString = nil
      return
    }
    
    if let givenFontDynamicType = fontDynamicType {
      configuration.fontBook = givenFontDynamicType
    }
    
    
    if let generatedAttributedString = DTAttributedTextContentView.htmlAttributedString(
      text: text, fontDynamicType: configuration.fontBook,
      color: color ?? configuration.defaultTextColor,
      htmlImageWidth: UIScreen.main.bounds.width,
      defaultLineHeightMultiple: AttributedStringBuilder.defaultHTMLLineHeightMultiple) {
      let candidateAttributedString = NSMutableAttributedString(attributedString: generatedAttributedString)
      candidateAttributedString.mutableString.removeTrailingWhitespace()
      originalAttributedString = candidateAttributedString
    } else {
      originalAttributedString = nil
    }
    
    setNeedsLayout()
  }
  
  //MARK: Helpers
  //=============
  fileprivate func preferredLayoutSize(for constrainedSize: CGSize) -> CGSize? {
    guard let layoutFrame = layouter.layoutFrame(
      with: CGRect.init(x: 0, y: 0, width: constrainedSize.width, height: 1),
      range: NSMakeRange(0, 0)) else {
        return nil
    }
    layoutFrame.lineBreakMode = .byTruncatingTail
    layoutFrame.truncationString = self.configuration.truncationString
    return layoutFrame.frame.size
  }
  
  fileprivate func preferredSize() -> CGSize? {
    guard isNodeLoaded, let textContentView = textContentView else {
      return nil
    }
    return textContentView.suggestedFrameSizeToFitEntireStringConstrainted(
      toWidth: constrainedSizeForCalculatedLayout.max.width)
  }
  
  func refreshLayout() {
    guard let calculatedSize = preferredSize() else {
      style.preferredSize = CGSize(width: 0, height: 0)
      return
    }
    style.preferredSize = calculatedSize
    // TODO: Call delegate
  }
  
  var shouldBeTruncated: Bool {
    guard let originalAttributedString = originalAttributedString else {
      return false
    }
    return originalAttributedString.string.count >= configuration.characterLengthOfCollapsedMessage
  }
}

                                  //******\\

//MARK: - DTAttributedTextContentViewDelegate
extension DynamicCommentMessageNode: DTAttributedTextContentViewDelegate {
  public func attributedTextContentView(
    _ attributedTextContentView: DTAttributedTextContentView!,
    didDraw layoutFrame: DTCoreTextLayoutFrame!,
    in context: CGContext!) {
  }
  
  public func attributedTextContentView(
    _ attributedTextContentView: DTAttributedTextContentView!,
    viewForLink url: URL!,
    identifier: String!,
    frame: CGRect) -> UIView! {
    let button = DTLinkButton(type: UIButtonType.custom)
    button.url = url
    button.frame = frame
    button.addTarget(self, action: #selector(didTapOnLinkButton(_:)), for: UIControlEvents.touchUpInside)
    return button
  }
  
  func didTapOnLinkButton(_ sender: DTLinkButton) {
    //TODO: Handle (call delegate)
  }
}

                                  //******\\

//MARK: - DynamicMode
extension DynamicCommentMessageNode {
  enum DynamicMode {
    case extended
    case collapsed
    case minimal
  }
}
  
                                  //******\\

//MARK: - Comment Attributed Links
extension DynamicCommentMessageNode {
  fileprivate enum CommentAttributedLinks {
    case more
    case wits(numberOfWits: Int)
    
    var attributedString: NSAttributedString {
      var handyAttributedString = NSMutableAttributedString()
      switch self {
      case .more:
        handyAttributedString.append(
          NSAttributedString(string: "...\(Strings.more().uppercased())", attributes:
            [
              NSFontAttributeName : FontDynamicType.footnote.font,
              NSForegroundColorAttributeName : ThemeManager.shared.currentTheme.defaultTextColor()
            ]
          )
        )
      case .wits(let numberOfWits):
        handyAttributedString.append(
          NSAttributedString(string: "\(Strings.wits(numberOfWits))", attributes:
            [
              NSFontAttributeName : FontDynamicType.caption1.font,
              NSForegroundColorAttributeName : ThemeManager.shared.currentTheme.colorNumber15()
            ]
          )
        )
      }
      
      handyAttributedString.addAttribute(
        DTLinkAttribute, value: self.url ,
        range: NSRange(location: 0, length: handyAttributedString.length))
      
      return handyAttributedString
    }
    
    var url: URL {
      switch self {
      case .more:
        return URL(string: "bookwitty://comment/read.more")!
      case .wits:
        return URL(string: "bookwitty://comment/number.of.wits")!
      }
    }
  }
}

                                  //******\\

//MARK: - Configuration
extension DynamicCommentMessageNode {
  struct Configuration {
    fileprivate var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var truncationString = AttributedStringBuilder(fontDynamicType: .body)
      .append(text: "...").attributedString
    fileprivate var fontBook: FontDynamicType = .body
    var numberOfLines: Int = 10000
    var characterLengthOfCollapsedMessage: Int = 300
  }
}
