//
//  FontDynamicType.swift
//  Bookwitty
//
//  Created by Marwan  on 1/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
enum FontDynamicType: String {
  case title1 = "title1"
  case title2 = "title2"
  case title3 = "title3"
  case title4 = "title4"
  case title5 = "title5"
  case body = "body"
  case body2 = "body2"
  case body3 = "body3"
  case headline = "headline"
  case callout = "callout"
  case subheadline = "subheadline"
  case footnote = "footnote"
  case caption1 = "caption1"
  case caption2 = "caption2"
  case caption3 = "caption3"
  case label1 = "label1"
  case label2 = "label2"
  case quote = "quote"
  
  
  var font: UIFont {
    
    let contentSize = UIApplication.shared.preferredContentSizeCategory
    let selectedSize = pointSize(forContentSize: contentSize)
    let selectedWeight = weight(forContentSize: contentSize)
    return fontForDynamicType(fontDynamicType: self, weight: selectedWeight, size: selectedSize)
  }
  
  private func pointSize(forContentSize contentSize: UIContentSizeCategory) -> CGFloat {
    return FontDynamicType.fontSizeTable[self.rawValue]![contentSize]!
  }
  
  private func weight(forContentSize contentSize: UIContentSizeCategory) -> Font.Weight {
    return FontDynamicType.fontWeightTable[self.rawValue]![contentSize]!
  }
  
  private func fontForDynamicType(fontDynamicType: FontDynamicType, weight: Font.Weight, size: CGFloat) -> UIFont {
    var selectedFont = Font.georgiaRegular
    
    switch (fontDynamicType, weight) {
    case (FontDynamicType.title1, _):
      selectedFont = Font.volkhovRegular
    case (FontDynamicType.title2, _):
      selectedFont = Font.volkhovRegular
    case (FontDynamicType.title3, _):
      selectedFont = Font.volkhovRegular
    case (FontDynamicType.title4, _):
      selectedFont = Font.volkhovBold
    case (FontDynamicType.title5, _):
      selectedFont = Font.ubuntuMedium
    case (FontDynamicType.body, _):
      selectedFont = Font.georgiaRegular
    case (FontDynamicType.body2, _):
      selectedFont = Font.georgiaRegular
    case (FontDynamicType.body3, _):
      selectedFont = Font.georgiaRegular
    case (FontDynamicType.headline, _):
      selectedFont = Font.ubuntuMedium
    case (FontDynamicType.callout, _):
      selectedFont = Font.ubuntuMedium
    case (FontDynamicType.subheadline, _):
      selectedFont = Font.ubuntuMedium
    case (FontDynamicType.footnote, _):
      selectedFont = Font.ubuntuMedium
    case (FontDynamicType.caption1, _):
      selectedFont = Font.ubuntuRegular
    case (FontDynamicType.caption2, _):
      selectedFont = Font.ubuntuRegular
    case (FontDynamicType.caption3, _):
      selectedFont = Font.ubuntuRegular
    case (FontDynamicType.label1, _):
      selectedFont = Font.georgiaRegular
    case (FontDynamicType.label2, _):
      selectedFont = Font.ubuntuRegular
    case (FontDynamicType.quote, _):
      selectedFont = Font.volkhovBoldItalic
    }
    
    return UIFont(name: selectedFont.rawValue, size: size)!
  }
}


extension FontDynamicType {
  fileprivate static var fontSizeTable: [String: [UIContentSizeCategory:CGFloat]] = [
    FontDynamicType.title1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 34,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 34,
      UIContentSizeCategory.accessibilityExtraLarge: 34,
      UIContentSizeCategory.accessibilityLarge: 34,
      UIContentSizeCategory.accessibilityMedium: 34,
      UIContentSizeCategory.extraExtraExtraLarge: 34,
      UIContentSizeCategory.extraExtraLarge: 32,
      UIContentSizeCategory.extraLarge: 30,
      UIContentSizeCategory.large: 28,
      UIContentSizeCategory.medium: 27,
      UIContentSizeCategory.small: 26,
      UIContentSizeCategory.extraSmall: 25
    ],
    FontDynamicType.title2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraLarge: 30,
      UIContentSizeCategory.accessibilityLarge: 30,
      UIContentSizeCategory.accessibilityMedium: 30,
      UIContentSizeCategory.extraExtraExtraLarge: 30,
      UIContentSizeCategory.extraExtraLarge: 28,
      UIContentSizeCategory.extraLarge: 26,
      UIContentSizeCategory.large: 24,
      UIContentSizeCategory.medium: 23,
      UIContentSizeCategory.small: 22,
      UIContentSizeCategory.extraSmall: 21
    ],
    FontDynamicType.title3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 26,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 26,
      UIContentSizeCategory.accessibilityExtraLarge: 26,
      UIContentSizeCategory.accessibilityLarge: 26,
      UIContentSizeCategory.accessibilityMedium: 26,
      UIContentSizeCategory.extraExtraExtraLarge: 26,
      UIContentSizeCategory.extraExtraLarge: 24,
      UIContentSizeCategory.extraLarge: 22,
      UIContentSizeCategory.large: 20,
      UIContentSizeCategory.medium: 19,
      UIContentSizeCategory.small: 18,
      UIContentSizeCategory.extraSmall: 17
    ],
    FontDynamicType.title4.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraLarge: 22,
      UIContentSizeCategory.accessibilityLarge: 22,
      UIContentSizeCategory.accessibilityMedium: 22,
      UIContentSizeCategory.extraExtraExtraLarge: 22,
      UIContentSizeCategory.extraExtraLarge: 20,
      UIContentSizeCategory.extraLarge: 18,
      UIContentSizeCategory.large: 16,
      UIContentSizeCategory.medium: 15,
      UIContentSizeCategory.small: 14,
      UIContentSizeCategory.extraSmall: 13
    ],
    FontDynamicType.title5.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraLarge: 20,
      UIContentSizeCategory.accessibilityLarge: 20,
      UIContentSizeCategory.accessibilityMedium: 20,
      UIContentSizeCategory.extraExtraExtraLarge: 20,
      UIContentSizeCategory.extraExtraLarge: 17,
      UIContentSizeCategory.extraLarge: 15,
      UIContentSizeCategory.large: 13,
      UIContentSizeCategory.medium: 12,
      UIContentSizeCategory.small: 11,
      UIContentSizeCategory.extraSmall: 10
    ],
    FontDynamicType.body.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 24,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 24,
      UIContentSizeCategory.accessibilityExtraLarge: 24,
      UIContentSizeCategory.accessibilityLarge: 24,
      UIContentSizeCategory.accessibilityMedium: 24,
      UIContentSizeCategory.extraExtraExtraLarge: 24,
      UIContentSizeCategory.extraExtraLarge: 22,
      UIContentSizeCategory.extraLarge: 20,
      UIContentSizeCategory.large: 18,
      UIContentSizeCategory.medium: 17,
      UIContentSizeCategory.small: 16,
      UIContentSizeCategory.extraSmall: 15
    ],
    FontDynamicType.body2.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraLarge: 22,
      UIContentSizeCategory.accessibilityLarge: 22,
      UIContentSizeCategory.accessibilityMedium: 22,
      UIContentSizeCategory.extraExtraExtraLarge: 22,
      UIContentSizeCategory.extraExtraLarge: 20,
      UIContentSizeCategory.extraLarge: 18,
      UIContentSizeCategory.large: 16,
      UIContentSizeCategory.medium: 15,
      UIContentSizeCategory.small: 14,
      UIContentSizeCategory.extraSmall: 13
    ],
    FontDynamicType.body3.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraLarge: 20,
      UIContentSizeCategory.accessibilityLarge: 20,
      UIContentSizeCategory.accessibilityMedium: 20,
      UIContentSizeCategory.extraExtraExtraLarge: 20,
      UIContentSizeCategory.extraExtraLarge: 18,
      UIContentSizeCategory.extraLarge: 16,
      UIContentSizeCategory.large: 14,
      UIContentSizeCategory.medium: 13,
      UIContentSizeCategory.small: 12,
      UIContentSizeCategory.extraSmall: 11
    ],
    FontDynamicType.headline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraLarge: 30,
      UIContentSizeCategory.accessibilityLarge: 30,
      UIContentSizeCategory.accessibilityMedium: 30,
      UIContentSizeCategory.extraExtraExtraLarge: 30,
      UIContentSizeCategory.extraExtraLarge: 28,
      UIContentSizeCategory.extraLarge: 26,
      UIContentSizeCategory.large: 24,
      UIContentSizeCategory.medium: 23,
      UIContentSizeCategory.small: 22,
      UIContentSizeCategory.extraSmall: 21
    ],
    FontDynamicType.callout.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 26,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 26,
      UIContentSizeCategory.accessibilityExtraLarge: 26,
      UIContentSizeCategory.accessibilityLarge: 26,
      UIContentSizeCategory.accessibilityMedium: 26,
      UIContentSizeCategory.extraExtraExtraLarge: 26,
      UIContentSizeCategory.extraExtraLarge: 24,
      UIContentSizeCategory.extraLarge: 22,
      UIContentSizeCategory.large: 20,
      UIContentSizeCategory.medium: 19,
      UIContentSizeCategory.small: 18,
      UIContentSizeCategory.extraSmall: 17
    ],
    FontDynamicType.subheadline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 24,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 24,
      UIContentSizeCategory.accessibilityExtraLarge: 24,
      UIContentSizeCategory.accessibilityLarge: 24,
      UIContentSizeCategory.accessibilityMedium: 24,
      UIContentSizeCategory.extraExtraExtraLarge: 24,
      UIContentSizeCategory.extraExtraLarge: 22,
      UIContentSizeCategory.extraLarge: 20,
      UIContentSizeCategory.large: 18,
      UIContentSizeCategory.medium: 17,
      UIContentSizeCategory.small: 16,
      UIContentSizeCategory.extraSmall: 15
    ],
    FontDynamicType.footnote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraLarge: 22,
      UIContentSizeCategory.accessibilityLarge: 22,
      UIContentSizeCategory.accessibilityMedium: 22,
      UIContentSizeCategory.extraExtraExtraLarge: 22,
      UIContentSizeCategory.extraExtraLarge: 20,
      UIContentSizeCategory.extraLarge: 18,
      UIContentSizeCategory.large: 16,
      UIContentSizeCategory.medium: 15,
      UIContentSizeCategory.small: 14,
      UIContentSizeCategory.extraSmall: 13
    ],
    FontDynamicType.caption1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 22,
      UIContentSizeCategory.accessibilityExtraLarge: 22,
      UIContentSizeCategory.accessibilityLarge: 22,
      UIContentSizeCategory.accessibilityMedium: 22,
      UIContentSizeCategory.extraExtraExtraLarge: 22,
      UIContentSizeCategory.extraExtraLarge: 20,
      UIContentSizeCategory.extraLarge: 18,
      UIContentSizeCategory.large: 16,
      UIContentSizeCategory.medium: 15,
      UIContentSizeCategory.small: 14,
      UIContentSizeCategory.extraSmall: 13
    ],
    FontDynamicType.caption2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 20,
      UIContentSizeCategory.accessibilityExtraLarge: 20,
      UIContentSizeCategory.accessibilityLarge: 20,
      UIContentSizeCategory.accessibilityMedium: 20,
      UIContentSizeCategory.extraExtraExtraLarge: 20,
      UIContentSizeCategory.extraExtraLarge: 18,
      UIContentSizeCategory.extraLarge: 16,
      UIContentSizeCategory.large: 14,
      UIContentSizeCategory.medium: 13,
      UIContentSizeCategory.small: 12,
      UIContentSizeCategory.extraSmall: 11
    ],
    FontDynamicType.caption3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraLarge: 18,
      UIContentSizeCategory.accessibilityLarge: 18,
      UIContentSizeCategory.accessibilityMedium: 18,
      UIContentSizeCategory.extraExtraExtraLarge: 18,
      UIContentSizeCategory.extraExtraLarge: 16,
      UIContentSizeCategory.extraLarge: 14,
      UIContentSizeCategory.large: 12,
      UIContentSizeCategory.medium: 11,
      UIContentSizeCategory.small: 10,
      UIContentSizeCategory.extraSmall: 9
    ],
    FontDynamicType.label1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraLarge: 18,
      UIContentSizeCategory.accessibilityLarge: 18,
      UIContentSizeCategory.accessibilityMedium: 18,
      UIContentSizeCategory.extraExtraExtraLarge: 18,
      UIContentSizeCategory.extraExtraLarge: 16,
      UIContentSizeCategory.extraLarge: 14,
      UIContentSizeCategory.large: 12,
      UIContentSizeCategory.medium: 11,
      UIContentSizeCategory.small: 10,
      UIContentSizeCategory.extraSmall: 9
    ],
    FontDynamicType.label2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 18,
      UIContentSizeCategory.accessibilityExtraLarge: 18,
      UIContentSizeCategory.accessibilityLarge: 18,
      UIContentSizeCategory.accessibilityMedium: 18,
      UIContentSizeCategory.extraExtraExtraLarge: 18,
      UIContentSizeCategory.extraExtraLarge: 16,
      UIContentSizeCategory.extraLarge: 14,
      UIContentSizeCategory.large: 12,
      UIContentSizeCategory.medium: 11,
      UIContentSizeCategory.small: 10,
      UIContentSizeCategory.extraSmall: 9
    ],
    FontDynamicType.quote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 30,
      UIContentSizeCategory.accessibilityExtraLarge: 30,
      UIContentSizeCategory.accessibilityLarge: 30,
      UIContentSizeCategory.accessibilityMedium: 30,
      UIContentSizeCategory.extraExtraExtraLarge: 30,
      UIContentSizeCategory.extraExtraLarge: 28,
      UIContentSizeCategory.extraLarge: 26,
      UIContentSizeCategory.large: 24,
      UIContentSizeCategory.medium: 23,
      UIContentSizeCategory.small: 22,
      UIContentSizeCategory.extraSmall: 21
    ]
  ]
  
  //============================================================================
  
  fileprivate static var fontWeightTable: [String: [UIContentSizeCategory:Font.Weight]] = [
    FontDynamicType.title1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.title2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.title3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.title4.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.title5.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.body.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.body2.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.body3.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.headline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.callout.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.subheadline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.footnote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.caption1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.caption2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.caption3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.label1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.label2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ],
    FontDynamicType.quote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraExtraLarge: .regular,
      UIContentSizeCategory.accessibilityExtraLarge: .regular,
      UIContentSizeCategory.accessibilityLarge: .regular,
      UIContentSizeCategory.accessibilityMedium: .regular,
      UIContentSizeCategory.extraExtraExtraLarge: .regular,
      UIContentSizeCategory.extraExtraLarge: .regular,
      UIContentSizeCategory.extraLarge: .regular,
      UIContentSizeCategory.large: .regular,
      UIContentSizeCategory.medium: .regular,
      UIContentSizeCategory.small: .regular,
      UIContentSizeCategory.extraSmall: .regular
    ]
  ]
}
