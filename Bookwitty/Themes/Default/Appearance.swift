//
//  Appearance.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol Themeable {
  func applyTheme()
}

protocol ThemeColor {
  func colorNumber1() -> UIColor
  func colorNumber2() -> UIColor
  func colorNumber3() -> UIColor
  func colorNumber4() -> UIColor
  func colorNumber5() -> UIColor
  func colorNumber6() -> UIColor
  func colorNumber7() -> UIColor
  func colorNumber8() -> UIColor
  func colorNumber9() -> UIColor
  func colorNumber10() -> UIColor
  func colorNumber11() -> UIColor
  func colorNumber12() -> UIColor
  func colorNumber13() -> UIColor
  func colorNumber14() -> UIColor
  func colorNumber15() -> UIColor
  func colorNumber16() -> UIColor
  func colorNumber17() -> UIColor
  func colorNumber18() -> UIColor
  func colorNumber19() -> UIColor
  func colorNumber20() -> UIColor
  func colorNumber21() -> UIColor
  func colorNumber22() -> UIColor
  func colorNumber23() -> UIColor
  
  func colorNumber19Highlighted() -> UIColor
  
  func defaultPrimaryButtonColor() -> UIColor
  func defaultPrimaryButtonHighlightedColor() -> UIColor
  func defaultSecondaryButtonColor() -> UIColor
  func defaultSecondaryButtonHighlightedColor() -> UIColor
  
  func defaultTextColor() -> UIColor
  func defaultGrayedTextColor() -> UIColor
  
  func defaultSeparatorColor() -> UIColor
}

protocol ThemeButtonsStyle {
  func stylePrimaryButton(button: UIButton)
  func styleSecondaryButton(button: UIButton)
  func stylePrimaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor)
  func styleSecondaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor)
}

protocol ThemeLabelsStyle {
  func styleLabel(label: UILabel)
}

protocol ThemeTextFieldsStyle {
  func styleTextField(textField: UITextField)
}

protocol Theme: ThemeColor, ThemeButtonsStyle, ThemeLabelsStyle, ThemeTextFieldsStyle {
  func initialize()
}

class ThemeManager {
  static let shared = ThemeManager()
  
  var currentTheme: Theme! {
    didSet{
      // TODO: Send notification for updating the layout throughout the app
    }
  }
  
  private init() {
    currentTheme = DefaultTheme()
  }
}
