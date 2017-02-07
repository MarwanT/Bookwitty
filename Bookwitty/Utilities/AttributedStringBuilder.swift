//
//  AttributedStringBuilder.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class AttributedStringBuilder {
  let attributedString: NSMutableAttributedString
  private let fontDynamicType: FontDynamicType

  init(fontDynamicType: FontDynamicType) {
    self.attributedString = NSMutableAttributedString()
    self.fontDynamicType = fontDynamicType
  }

  func append(text: String, fontDynamicType: FontDynamicType? = nil, color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
              underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone) -> Self {
    let atrString = NSAttributedString(string: text, attributes: [ NSFontAttributeName : fontDynamicType?.font ?? self.fontDynamicType.font,
                                                                   NSForegroundColorAttributeName : color,
                                                                   NSUnderlineStyleAttributeName: underlineStyle.rawValue
      ])

    attributedString.append(atrString)
    return self
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
