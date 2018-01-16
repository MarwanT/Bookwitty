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
  case body = "body"
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
    case (FontDynamicType.body, _):
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
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 33,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 33,
      UIContentSizeCategory.accessibilityExtraLarge: 33,
      UIContentSizeCategory.accessibilityLarge: 33,
      UIContentSizeCategory.accessibilityMedium: 33,
      UIContentSizeCategory.extraExtraExtraLarge: 33,
      UIContentSizeCategory.extraExtraLarge: 31,
      UIContentSizeCategory.extraLarge: 29,
      UIContentSizeCategory.large: 27,
      UIContentSizeCategory.medium: 26,
      UIContentSizeCategory.small: 25,
      UIContentSizeCategory.extraSmall: 24
    ],
    FontDynamicType.title2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraLarge: 29,
      UIContentSizeCategory.accessibilityLarge: 29,
      UIContentSizeCategory.accessibilityMedium: 29,
      UIContentSizeCategory.extraExtraExtraLarge: 29,
      UIContentSizeCategory.extraExtraLarge: 27,
      UIContentSizeCategory.extraLarge: 25,
      UIContentSizeCategory.large: 23,
      UIContentSizeCategory.medium: 22,
      UIContentSizeCategory.small: 21,
      UIContentSizeCategory.extraSmall: 20
    ],
    FontDynamicType.title3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 25,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 25,
      UIContentSizeCategory.accessibilityExtraLarge: 25,
      UIContentSizeCategory.accessibilityLarge: 25,
      UIContentSizeCategory.accessibilityMedium: 25,
      UIContentSizeCategory.extraExtraExtraLarge: 25,
      UIContentSizeCategory.extraExtraLarge: 23,
      UIContentSizeCategory.extraLarge: 21,
      UIContentSizeCategory.large: 19,
      UIContentSizeCategory.medium: 18,
      UIContentSizeCategory.small: 17,
      UIContentSizeCategory.extraSmall: 16
    ],
    FontDynamicType.title4.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraLarge: 21,
      UIContentSizeCategory.accessibilityLarge: 21,
      UIContentSizeCategory.accessibilityMedium: 21,
      UIContentSizeCategory.extraExtraExtraLarge: 21,
      UIContentSizeCategory.extraExtraLarge: 19,
      UIContentSizeCategory.extraLarge: 17,
      UIContentSizeCategory.large: 15,
      UIContentSizeCategory.medium: 14,
      UIContentSizeCategory.small: 13,
      UIContentSizeCategory.extraSmall: 12
    ],
    FontDynamicType.body.rawValue: [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 23,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 23,
      UIContentSizeCategory.accessibilityExtraLarge: 23,
      UIContentSizeCategory.accessibilityLarge: 23,
      UIContentSizeCategory.accessibilityMedium: 23,
      UIContentSizeCategory.extraExtraExtraLarge: 23,
      UIContentSizeCategory.extraExtraLarge: 21,
      UIContentSizeCategory.extraLarge: 19,
      UIContentSizeCategory.large: 17,
      UIContentSizeCategory.medium: 16,
      UIContentSizeCategory.small: 15,
      UIContentSizeCategory.extraSmall: 14
    ],
    FontDynamicType.headline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraLarge: 29,
      UIContentSizeCategory.accessibilityLarge: 29,
      UIContentSizeCategory.accessibilityMedium: 29,
      UIContentSizeCategory.extraExtraExtraLarge: 29,
      UIContentSizeCategory.extraExtraLarge: 27,
      UIContentSizeCategory.extraLarge: 25,
      UIContentSizeCategory.large: 23,
      UIContentSizeCategory.medium: 22,
      UIContentSizeCategory.small: 21,
      UIContentSizeCategory.extraSmall: 20
    ],
    FontDynamicType.callout.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 25,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 25,
      UIContentSizeCategory.accessibilityExtraLarge: 25,
      UIContentSizeCategory.accessibilityLarge: 25,
      UIContentSizeCategory.accessibilityMedium: 25,
      UIContentSizeCategory.extraExtraExtraLarge: 25,
      UIContentSizeCategory.extraExtraLarge: 23,
      UIContentSizeCategory.extraLarge: 21,
      UIContentSizeCategory.large: 19,
      UIContentSizeCategory.medium: 18,
      UIContentSizeCategory.small: 17,
      UIContentSizeCategory.extraSmall: 16
    ],
    FontDynamicType.subheadline.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 23,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 23,
      UIContentSizeCategory.accessibilityExtraLarge: 23,
      UIContentSizeCategory.accessibilityLarge: 23,
      UIContentSizeCategory.accessibilityMedium: 23,
      UIContentSizeCategory.extraExtraExtraLarge: 23,
      UIContentSizeCategory.extraExtraLarge: 21,
      UIContentSizeCategory.extraLarge: 19,
      UIContentSizeCategory.large: 17,
      UIContentSizeCategory.medium: 16,
      UIContentSizeCategory.small: 15,
      UIContentSizeCategory.extraSmall: 14
    ],
    FontDynamicType.footnote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraLarge: 21,
      UIContentSizeCategory.accessibilityLarge: 21,
      UIContentSizeCategory.accessibilityMedium: 21,
      UIContentSizeCategory.extraExtraExtraLarge: 21,
      UIContentSizeCategory.extraExtraLarge: 19,
      UIContentSizeCategory.extraLarge: 17,
      UIContentSizeCategory.large: 15,
      UIContentSizeCategory.medium: 14,
      UIContentSizeCategory.small: 13,
      UIContentSizeCategory.extraSmall: 12
    ],
    FontDynamicType.caption1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 21,
      UIContentSizeCategory.accessibilityExtraLarge: 21,
      UIContentSizeCategory.accessibilityLarge: 21,
      UIContentSizeCategory.accessibilityMedium: 21,
      UIContentSizeCategory.extraExtraExtraLarge: 21,
      UIContentSizeCategory.extraExtraLarge: 19,
      UIContentSizeCategory.extraLarge: 17,
      UIContentSizeCategory.large: 15,
      UIContentSizeCategory.medium: 14,
      UIContentSizeCategory.small: 13,
      UIContentSizeCategory.extraSmall: 12
    ],
    FontDynamicType.caption2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 19,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 19,
      UIContentSizeCategory.accessibilityExtraLarge: 19,
      UIContentSizeCategory.accessibilityLarge: 19,
      UIContentSizeCategory.accessibilityMedium: 19,
      UIContentSizeCategory.extraExtraExtraLarge: 19,
      UIContentSizeCategory.extraExtraLarge: 17,
      UIContentSizeCategory.extraLarge: 15,
      UIContentSizeCategory.large: 13,
      UIContentSizeCategory.medium: 12,
      UIContentSizeCategory.small: 11,
      UIContentSizeCategory.extraSmall: 10
    ],
    FontDynamicType.caption3.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraLarge: 17,
      UIContentSizeCategory.accessibilityLarge: 17,
      UIContentSizeCategory.accessibilityMedium: 17,
      UIContentSizeCategory.extraExtraExtraLarge: 17,
      UIContentSizeCategory.extraExtraLarge: 15,
      UIContentSizeCategory.extraLarge: 13,
      UIContentSizeCategory.large: 11,
      UIContentSizeCategory.medium: 10,
      UIContentSizeCategory.small: 9,
      UIContentSizeCategory.extraSmall: 8
    ],
    FontDynamicType.label1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraLarge: 17,
      UIContentSizeCategory.accessibilityLarge: 17,
      UIContentSizeCategory.accessibilityMedium: 17,
      UIContentSizeCategory.extraExtraExtraLarge: 17,
      UIContentSizeCategory.extraExtraLarge: 15,
      UIContentSizeCategory.extraLarge: 13,
      UIContentSizeCategory.large: 11,
      UIContentSizeCategory.medium: 10,
      UIContentSizeCategory.small: 9,
      UIContentSizeCategory.extraSmall: 8
    ],
    FontDynamicType.label2.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 17,
      UIContentSizeCategory.accessibilityExtraLarge: 17,
      UIContentSizeCategory.accessibilityLarge: 17,
      UIContentSizeCategory.accessibilityMedium: 17,
      UIContentSizeCategory.extraExtraExtraLarge: 17,
      UIContentSizeCategory.extraExtraLarge: 15,
      UIContentSizeCategory.extraLarge: 13,
      UIContentSizeCategory.large: 11,
      UIContentSizeCategory.medium: 10,
      UIContentSizeCategory.small: 9,
      UIContentSizeCategory.extraSmall: 8
    ],
    FontDynamicType.quote.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 29,
      UIContentSizeCategory.accessibilityExtraLarge: 29,
      UIContentSizeCategory.accessibilityLarge: 29,
      UIContentSizeCategory.accessibilityMedium: 29,
      UIContentSizeCategory.extraExtraExtraLarge: 29,
      UIContentSizeCategory.extraExtraLarge: 27,
      UIContentSizeCategory.extraLarge: 25,
      UIContentSizeCategory.large: 23,
      UIContentSizeCategory.medium: 22,
      UIContentSizeCategory.small: 21,
      UIContentSizeCategory.extraSmall: 20
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
