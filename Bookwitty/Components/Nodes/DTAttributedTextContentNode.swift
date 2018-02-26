//
//  DTAttributedTextContentNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import DTCoreText

extension DTAttributedTextContentView {
  static func htmlAttributedString(text: String, fontDynamicType: FontDynamicType? = nil,
                                   color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                                   linkColor: UIColor =  ThemeManager.shared.currentTheme.colorNumber19(),
                                   linkDecoration: Bool = false,
                                   htmlImageWidth: CGFloat = UIScreen.main.bounds.width,
                                   defaultLineHeightMultiple: CGFloat = 1.0) -> NSAttributedString? {
    let font: UIFont = fontDynamicType?.font ?? FontDynamicType.footnote.font

    let options: [String : Any] = [
      DTDefaultFontSize: CGFloat(font.pointSize),
      DTDefaultFontName: font.fontName,
      DTDefaultFontFamily: font.familyName,
      DTUseiOS6Attributes: NSNumber(value: true),
      DTDefaultTextColor: color,
      DTDefaultLinkColor: linkColor,
      DTDefaultLinkDecoration: linkDecoration,
      DTDefaultLineHeightMultiplier: defaultLineHeightMultiple,
      NSTextSizeMultiplierDocumentOption: CGFloat(1.0),
      DTMaxImageSize: CGSize(width: htmlImageWidth, height: htmlImageWidth),
      DTDocumentPreserveTrailingSpaces: false]

    guard let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
      return nil
    }

    guard let attributedString = NSAttributedString(htmlData: data, options: options, documentAttributes: nil) else {
      return nil
    }

    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

    return fixSmallFontIssues(attributedHtml: mutableAttributedString, usedFont: font)
  }

  static func fixSmallFontIssues(attributedHtml: NSMutableAttributedString?, usedFont: UIFont) -> NSMutableAttributedString? {
    if let attributedHtml = attributedHtml {
      let range = NSRange(location: 0, length: attributedHtml.length)
      attributedHtml.enumerateAttribute(NSFontAttributeName, in: range, options: [], using: { (value, range, stop) in
        if let font = value as? UIFont, font.pointSize < 4.0 {
          attributedHtml.removeAttribute(NSFontAttributeName, range: range)
          attributedHtml.addAttribute(NSFontAttributeName, value: font.withSize(usedFont.pointSize), range: range)
        }
      })
      return attributedHtml
    }
    return nil
  }
}

protocol DTAttributedTextContentNodeDelegate: class {
  func attributedTextContentNodeNeedsLayout(node: ASCellNode)
  func attributedTextContentNode(node: ASCellNode, button: DTLinkButton, didTapOnLink link: URL)
}

class DTAttributedTextContentNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var textContentView: DTAttributedTextContentView!
  weak var delegate: DTAttributedTextContentNodeDelegate?

  convenience override init() {
    self.init(viewBlock: { () -> UIView in
      let textContentView = DTAttributedTextContentView()
      return textContentView
    })

    textContentView = self.view as! DTAttributedTextContentView
    textContentView.delegate = self
  }

  func htmlString(text: String?, fontDynamicType: FontDynamicType? = nil,
                  color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                  htmlImageWidth: CGFloat = UIScreen.main.bounds.width) {
    guard let text = text else {
      textContentView.attributedString = nil
      return
    }

    let attrStr = DTAttributedTextContentView.htmlAttributedString(text: text, fontDynamicType: fontDynamicType, color: color, htmlImageWidth: htmlImageWidth, defaultLineHeightMultiple: AttributedStringBuilder.defaultHTMLLineHeightMultiple)
    textContentView.attributedString = attrStr
  }
}

extension DTAttributedTextContentNode: DTLazyImageViewDelegate, DTAttributedTextContentViewDelegate {
  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
    let button = DTLinkButton(type: UIButtonType.custom)
    button.url = url
    button.frame = frame
    button.addTarget(self, action: #selector(didTapOnLinkButton(_:)), for: UIControlEvents.touchUpInside)
    return button
  }

  func didTapOnLinkButton(_ sender: DTLinkButton?) {
    if let sender = sender, let url = sender.url {
      delegate?.attributedTextContentNode(node: self, button: sender, didTapOnLink: url)
    }
  }

  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, didDraw layoutFrame: DTCoreTextLayoutFrame!, in context: CGContext!) {
    let intrinsicContentSize = attributedTextContentView.intrinsicContentSize()
    if intrinsicContentSize.height != -1 && intrinsicContentSize.width != -1 {
      style.preferredSize = intrinsicContentSize
    }
    setNeedsLayout()
    delegate?.attributedTextContentNodeNeedsLayout(node: self)
  }

  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewFor attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
    if let attachment = attachment as? DTImageTextAttachment {
      let imageView: DTLazyImageView = DTLazyImageView()
      imageView.contentMode = UIViewContentMode.scaleAspectFit
      imageView.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
      imageView.delegate = self
      imageView.shouldShowProgressiveDownload = true
      // url for deferred loading
      imageView.url = attachment.contentURL
      return imageView
    }
    return DTLazyImageView()
  }

  public func lazyImageView(_ lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
    // update all attachments that matching this URL
    if let contentView = textContentView {
      if let layoutFrame = contentView.layoutFrame {
        if let list = layoutFrame.textAttachments()?.filter({ $0 is DTImageTextAttachment }) {
          list.forEach({ (dtTextAttachment) in
            if let item = dtTextAttachment as? DTImageTextAttachment {
              if let image = lazyImageView.image {
                let width: CGFloat = UIScreen.main.bounds.width - (internalMargin * CGFloat(2.0))
                let ratio = (image.size.width / width)
                let newSize = CGSize(width: width, height: image.size.height / ratio)
                let resizedImage = image.resizeImage(width: newSize.width,
                                                     height: newSize.height)
                item.image = resizedImage
                item.originalSize = item.image.size
                item.displaySize = item.image.size
                lazyImageView.bounds = CGRect(x: 0, y: 0, width: item.image.size.width, height: item.image.size.height)
              }
            }
          })
        }
      }
    }

    // need to reset the layouter because otherwise we get the old framesetter or cached layout frames
    textContentView.layouter = nil

    // here we're layouting the entire string,
    // might be more efficient to only relayout the paragraphs that contain these attachments
    textContentView.relayoutText()
  }
}

extension DTAttributedLabelNode: DTAttributedTextContentViewDelegate {
  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, didDraw layoutFrame: DTCoreTextLayoutFrame!, in context: CGContext!) {
    if style.width.value == 0.0 {
      style.width = ASDimensionMake(UIScreen.main.bounds.width)
    }
    //Recalculate height and set it on the node then relayout
    let size = attributedTextContentView.suggestedFrameSizeToFitEntireStringConstrainted(toWidth: style.preferredSize.width)
    let newSize = attributedTextContentView.sizeThatFits(size)
    style.preferredSize = newSize
    computedHeight = newSize.height
    setNeedsLayout()
    delegate?.attributedTextContentNodeNeedsLayout(node: self)
  }

  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
    let button = DTLinkButton(type: UIButtonType.custom)
    button.url = url
    button.frame = frame
    button.addTarget(self, action: #selector(didTapOnLinkButton(_:)), for: UIControlEvents.touchUpInside)
    return button
  }

  func didTapOnLinkButton(_ sender: DTLinkButton?) {
    //TODO: Tap on Link action delegation
    if let sender = sender, let url = sender.url {
      delegate?.attributedTextContentNode(node: self, button: sender, didTapOnLink: url)
    }
  }
}

/** Use with text of html content that does not 
 * need image layouting and needs max number of lines.
 * 
 * Use Only width and maxNumberOfLines to adjus the size of the node
 * Note: Using style.* will have no effect
 * Use: .maxNumberOfLines for max lines and Height
 * Use: .width for max width
 * Note: You can not use the height directly
 **/

class DTAttributedLabelNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var textContentView: DTAttributedLabel?
  var delegate: DTAttributedTextContentNodeDelegate?
  var maxNumberOfLines: Int = 0 {
    didSet {
      setNeedsDisplay()
    }
  }
  var width: CGFloat = 0.0 {
    didSet {
      style.preferredSize = CGSize(width: width, height: height)
    }
  }

  fileprivate var computedHeight: CGFloat = 0.0
  
  private var height: CGFloat {
    return computedHeight == 0.0 ? maxHeight : computedHeight
  }
  private var maxHeight: CGFloat = 0.0 {
    didSet {
      //Height will be updated [shrinked if needed] when html is ready
      style.preferredSize = CGSize(width: width, height: height)
    }
  }
  private var fontLineHeight: CGFloat = FontDynamicType.body.font.lineHeight
  private var attributedString: NSAttributedString? {
    didSet {
      textContentView?.attributedString = attributedString
    }
  }

  override convenience init() {
    self.init(viewBlock: { () -> UIView in
      let textContentView = DTAttributedLabel()
      return textContentView
    })
  }

  override func didLoad() {
    super.didLoad()
    textContentView = self.view as? DTAttributedLabel
    textContentView?.delegate = self
    textContentView?.lineBreakMode = .byTruncatingTail
    textContentView?.truncationString = AttributedStringBuilder(fontDynamicType: .body).append(text: "...").attributedString
    textContentView?.numberOfLines = maxNumberOfLines
    textContentView?.attributedString = attributedString
  }

  func htmlString(text: String?, fontDynamicType: FontDynamicType? = nil,
                  color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor()) {
    guard let text = text else {
      return
    }
    attributedString = htmlAttributedString(text: text,
                                                            fontDynamicType: fontDynamicType,
                                                            color:  color)
  }

  func htmlAttributedString(text: String, fontDynamicType: FontDynamicType? = nil,
                                    color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                                    htmlImageWidth: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString? {

    let font: UIFont = fontDynamicType?.font ?? FontDynamicType.footnote.font
    //Set the font line height
    fontLineHeight = font.lineHeight

    //Update max-height
    self.maxHeight = CGFloat(fontLineHeight) * CGFloat(maxNumberOfLines)

    return DTAttributedTextContentView.htmlAttributedString(text: text, fontDynamicType: fontDynamicType, color: color, htmlImageWidth: htmlImageWidth, defaultLineHeightMultiple: AttributedStringBuilder.defaultHTMLLineHeightMultiple)
  }

  func set(attributedString: NSAttributedString) {
    self.attributedString = attributedString
  }
}


