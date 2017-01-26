//
//  FontDynamicType.swift
//  Bookwitty
//
//  Created by Marwan  on 1/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
enum FontDynamicType: String {
  case headlineLarge = "headlineLarge"
  case headlineMenium = "headlineMenium"
  case headlineSmall = "headlineSmall"
  case headlineXSmall = "headlineXSmall"
  case body = "body"
  case titleLarge = "titleLarge"
  case titleMedium = "titleMedium"
  case titleSmall = "titleSmall"
  case labelHighlight = "labelHighlight"
  case label = "label"
  case captions = "captions"
}


extension FontDynamicType {
  fileprivate static var fontSizeTable: [String: [UIContentSizeCategory:CGFloat]] = [
    FontDynamicType.headlineLarge.rawValue : [
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
      UIContentSizeCategory.extraSmall: 27,
      UIContentSizeCategory.unspecified: 30
    ],
    FontDynamicType.headlineMenium.rawValue : [
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
      UIContentSizeCategory.extraSmall: 21,
      UIContentSizeCategory.unspecified: 24
    ],
    FontDynamicType.headlineSmall.rawValue : [
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
      UIContentSizeCategory.extraSmall: 14,
      UIContentSizeCategory.unspecified: 20
    ],
    FontDynamicType.headlineXSmall.rawValue : [
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
      UIContentSizeCategory.extraSmall: 15,
      UIContentSizeCategory.unspecified: 18
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
      UIContentSizeCategory.extraSmall: 15,
      UIContentSizeCategory.unspecified: 18
    ],
    FontDynamicType.titleLarge.rawValue : [
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
      UIContentSizeCategory.extraSmall: 21,
      UIContentSizeCategory.unspecified: 24
    ],
    FontDynamicType.titleMedium.rawValue : [
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
      UIContentSizeCategory.extraSmall: 14,
      UIContentSizeCategory.unspecified: 20
    ],
    FontDynamicType.titleSmall.rawValue : [
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
      UIContentSizeCategory.extraSmall: 15,
      UIContentSizeCategory.unspecified: 18
    ],
    FontDynamicType.labelHighlight.rawValue : [
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
      UIContentSizeCategory.extraSmall: 13,
      UIContentSizeCategory.unspecified: 16
    ],
    FontDynamicType.label.rawValue : [
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
      UIContentSizeCategory.extraSmall: 13,
      UIContentSizeCategory.unspecified: 16
    ],
    FontDynamicType.captions.rawValue : [
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
      UIContentSizeCategory.extraSmall: 11,
      UIContentSizeCategory.unspecified: 14
    ]
  ]
}
