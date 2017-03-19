//
//  AttributedStringBuilder.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class AttributedStringBuilder {
  static let defaultLineHeightMultiple: CGFloat = 1.25
  static let defaultHTMLLineHeightMultiple: CGFloat = 1.30

  let attributedString: NSMutableAttributedString
  private let fontDynamicType: FontDynamicType

  init(fontDynamicType: FontDynamicType) {
    self.attributedString = NSMutableAttributedString()
    self.fontDynamicType = fontDynamicType
  }

  func append(text: String, fontDynamicType: FontDynamicType? = nil, color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
              underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
              strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
              fromHtml: Bool = false, htmlImageWidth: CGFloat = UIScreen.main.bounds.width) -> Self {
    if fromHtml, let htmlAtrString = htmlAttributedString(text: text, fontDynamicType: fontDynamicType, color: color,
                                                          underlineStyle: underlineStyle, strikeThroughStyle: strikeThroughStyle,
                                                          htmlImageWidth: htmlImageWidth) {
      attributedString.append(htmlAtrString)
      return self
    }

    let atrString = NSAttributedString(string: text, attributes: [
      NSFontAttributeName : fontDynamicType?.font ?? self.fontDynamicType.font,
      NSForegroundColorAttributeName : color,
      NSUnderlineStyleAttributeName: underlineStyle.rawValue,
      NSStrikethroughStyleAttributeName: strikeThroughStyle.rawValue,
      NSDocumentTypeDocumentAttribute: fromHtml ? NSHTMLTextDocumentType : NSPlainTextDocumentType
      ])

    attributedString.append(atrString)
    return self
  }

  private func htmlAttributedString(text: String, fontDynamicType: FontDynamicType? = nil, color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
                                    underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    strikeThroughStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone,
                                    htmlImageWidth: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString? {
    guard let data = text.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
      return nil
    }
    guard let html = try? NSMutableAttributedString(
      data: data,
      options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
      documentAttributes: nil) else {
        return nil
    }
    let rangeA = NSRange(location: 0, length: html.string.characters.count)
    html.addAttributes([NSFontAttributeName : fontDynamicType?.font ?? self.fontDynamicType.font,
                        NSForegroundColorAttributeName : color,
                        NSUnderlineStyleAttributeName: underlineStyle.rawValue,
                        NSStrikethroughStyleAttributeName: strikeThroughStyle.rawValue], range: rangeA)

    let range = NSRange(location: 0, length: html.string.characters.count)
    html.enumerateAttribute(NSAttachmentAttributeName, in: range, options: [], using: { (value, range, stop) in
      if let attachment = value as? NSTextAttachment {
        guard let image = attachment.image(forBounds: UIScreen.main.bounds, textContainer: NSTextContainer(), characterIndex: range.location) else {
          return
        }
        let ratio = (image.size.width / htmlImageWidth)
        let resizedImage = image.resizeImage(width: htmlImageWidth, height: image.size.height / ratio)
        attachment.image = resizedImage
        attachment.bounds = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
      }
    })

    return html
  }

  /**
   * Discussion:
   * Use this function as the last part of your builder to apply the paragraph styling on all parts.
   * Note: If this function was used in the beginning it will not work
   */
  func applyParagraphStyling(lineSpacing: CGFloat = 10, alignment: NSTextAlignment = NSTextAlignment.natural) -> Self {
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.alignment = alignment
    
    let range = NSRange(location: 0, length: attributedString.string.characters.count)

    attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
    return self
  }
  
}
