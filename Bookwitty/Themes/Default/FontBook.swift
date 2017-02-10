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
  case body = "body"
  case headline = "headline"
  case callout = "callout"
  case subheadline = "subheadline"
  case footnote = "footnote"
  case caption1 = "caption1"
  case caption2 = "caption2"
  case label = "label"
  
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
      selectedFont = Font.volkhov
    case (FontDynamicType.title2, _):
      selectedFont = Font.volkhov
    case (FontDynamicType.title3, _):
      selectedFont = Font.volkhov
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
    case (FontDynamicType.label, _):
      selectedFont = Font.ubuntuMedium
    }
    
    return UIFont(name: selectedFont.rawValue, size: size)!
  }
}


extension FontDynamicType {
  fileprivate static var fontSizeTable: [String: [UIContentSizeCategory:CGFloat]] = [
    FontDynamicType.title1.rawValue : [
      UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 36,
      UIContentSizeCategory.accessibilityExtraExtraLarge: 36,
      UIContentSizeCategory.accessibilityExtraLarge: 36,
      UIContentSizeCategory.accessibilityLarge: 36,
      UIContentSizeCategory.accessibilityMedium: 36,
      UIContentSizeCategory.extraExtraExtraLarge: 36,
      UIContentSizeCategory.extraExtraLarge: 34,
      UIContentSizeCategory.extraLarge: 32,
      UIContentSizeCategory.large: 30,
      UIContentSizeCategory.medium: 29,
      UIContentSizeCategory.small: 28,
      UIContentSizeCategory.extraSmall: 27
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
      UIContentSizeCategory.medium: 18,
      UIContentSizeCategory.small: 16,
      UIContentSizeCategory.extraSmall: 14
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
      UIContentSizeCategory.medium: 18,
      UIContentSizeCategory.small: 16,
      UIContentSizeCategory.extraSmall: 14
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
    FontDynamicType.label.rawValue : [
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
    FontDynamicType.label.rawValue : [
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
