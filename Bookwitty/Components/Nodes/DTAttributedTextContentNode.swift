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

protocol DTAttributedTextContentNodeDelegate {
  func attributedTextContentNodeNeedsLayout(node: DTAttributedTextContentNode)
}

class DTAttributedTextContentNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var textContentView: DTAttributedTextContentView!
  var delegate: DTAttributedTextContentNodeDelegate?

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
                  underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                  strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                  htmlImageWidth: CGFloat = UIScreen.main.bounds.width) {
    guard let text = text else {
      textContentView.attributedString = nil
      return
    }
    textContentView.attributedString = htmlAttributedString(text: text,
                                                            fontDynamicType: fontDynamicType,
                                                            color:  color,
                                                            underlineStyle: underlineStyle,
                                                            strikeThroughStyle: strikeThroughStyle,
                                                            htmlImageWidth: htmlImageWidth)
  }

  private func htmlAttributedString(text: String, fontDynamicType: FontDynamicType? = nil,
                                    color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                                    underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    htmlImageWidth: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString? {

    let font: UIFont = fontDynamicType?.font ?? FontDynamicType.footnote.font

    let options: [String : Any] = [
      DTDefaultFontSize: NSNumber(value: Float(font.pointSize)),
      DTDefaultFontName: font.fontName,
      DTDefaultFontFamily: font.familyName,
      DTUseiOS6Attributes: NSNumber(value: true),
      DTDefaultTextColor: color,
      DTMaxImageSize: CGSize(width: htmlImageWidth, height: htmlImageWidth)]
    guard let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
      return nil
    }

    guard let attributedString = NSAttributedString(htmlData: data, options: options, documentAttributes: nil) else {
      return nil
    }

    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
    return mutableAttributedString
  }
}

extension DTAttributedTextContentNode: DTLazyImageViewDelegate, DTAttributedTextContentViewDelegate {
  public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, didDraw layoutFrame: DTCoreTextLayoutFrame!, in context: CGContext!) {
    style.preferredSize = attributedTextContentView.intrinsicContentSize()
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


/** Use with text of html content that does not 
 * need image layouting and needs max number of lines.
 * 
 * Use Only width and maxNumberOfLines to adjus the size of the node
 * Note: Using style.* will have no effect
 **/

class DTAttributedLabelNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var textContentView: DTAttributedLabel!
  var delegate: DTAttributedTextContentNodeDelegate?
  var maxNumberOfLines: Int = 0 {
    didSet {
      textContentView.numberOfLines = maxNumberOfLines
      setNeedsLayout()
    }
  }
  var width: CGFloat = 0.0 {
    didSet {
      style.preferredSize = CGSize(width: width, height: maxHeight)
    }
  }
  private var maxHeight: CGFloat = 0.0 {
    didSet {
      //Height will be updated [shrinked if needed] when html is ready
      style.preferredSize = CGSize(width: width, height: maxHeight)
    }
  }

  override convenience init() {
    self.init(viewBlock: { () -> UIView in
      let textContentView = DTAttributedLabel()
      return textContentView
    })

    textContentView = self.view as! DTAttributedLabel
    textContentView.delegate = self

  }

  func htmlString(text: String?, fontDynamicType: FontDynamicType? = nil,
                  color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                  underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                  strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                  htmlImageWidth: CGFloat = UIScreen.main.bounds.width) {
    guard let text = text else {
      textContentView.attributedString = nil
      return
    }

    textContentView.attributedString = htmlAttributedString(text: text,
                                                            fontDynamicType: fontDynamicType,
                                                            color:  color,
                                                            underlineStyle: underlineStyle,
                                                            strikeThroughStyle: strikeThroughStyle,
                                                            htmlImageWidth: htmlImageWidth)
  }

  private func htmlAttributedString(text: String, fontDynamicType: FontDynamicType? = nil,
                                    color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                                    underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    htmlImageWidth: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString? {

    let font: UIFont = fontDynamicType?.font ?? FontDynamicType.footnote.font
    //Update max-height
    self.maxHeight = CGFloat(font.lineHeight) * CGFloat(maxNumberOfLines)

    let options: [String : Any] = [
      DTDefaultFontSize: NSNumber(value: Float(font.pointSize)),
      DTDefaultFontName: font.fontName,
      DTDefaultFontFamily: font.familyName,
      DTUseiOS6Attributes: NSNumber(value: true),
      DTDefaultTextColor: color,
      DTMaxImageSize: CGSize(width: htmlImageWidth, height: htmlImageWidth)]
    guard let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
      return nil
    }

    guard let attributedString = NSAttributedString(htmlData: data, options: options, documentAttributes: nil) else {
      return nil
    }

    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
    return mutableAttributedString
  }
}


