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
  fileprivate var configuration = Configuration()
  
  // MARK: Content Variables
  //========================
  private var attributedString: NSAttributedString? {
    didSet {
      layouter.attributedString = attributedString
      textContentView?.attributedString = attributedString
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
    self.textContentView?.attributedString = self.attributedString
  }
  
  // MARK: APIs
  //===========
  func htmlString(text: String?, fontDynamicType: FontDynamicType? = nil,
                  color: UIColor? = nil) {
    guard let text = text else {
      attributedString = nil
      return
    }
    
    if let givenFontDynamicType = fontDynamicType {
      configuration.fontBook = givenFontDynamicType
    }
    
    attributedString = DTAttributedTextContentView.htmlAttributedString(
      text: text, fontDynamicType: configuration.fontBook,
      color: color ?? configuration.defaultTextColor,
      htmlImageWidth: UIScreen.main.bounds.width,
      defaultLineHeightMultiple: AttributedStringBuilder.defaultHTMLLineHeightMultiple)
    
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
    return nil
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
  }
}
