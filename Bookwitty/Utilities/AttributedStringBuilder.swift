//
//  AttributedStringBuilder.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class AttributedStringBuilder {
  let attributedString = NSMutableAttributedString()
  private let fontDynamicType: FontDynamicType

  init(fontDynamicType: FontDynamicType) {
    self.fontDynamicType = fontDynamicType
  }

  func append(text: String, fontDynamicType: FontDynamicType? = nil, color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor(),
              underlineStyle: NSUnderlineStyle = NSUnderlineStyle.styleNone) -> Self {
    let atrString = NSAttributedString(string: text, attributes: [ NSFontAttributeName : fontDynamicType?.font ?? self.fontDynamicType.font,
                                                                   NSForegroundColorAttributeName : color,
                                                                   NSUnderlineStyleAttributeName: underlineStyle.rawValue])

    attributedString.append(atrString)
    return self
  }

}
