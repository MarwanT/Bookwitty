//
//  DefaultTheme.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import TTTAttributedLabel

final class DefaultTheme: Theme {
  func initialize() {
    // Initialize navigation bar and other stuff
    
    let appearance = UINavigationBar.appearance()
    appearance.barTintColor = self.colorNumber23()
    appearance.tintColor = self.colorNumber20()
    appearance.isTranslucent = false
    appearance.titleTextAttributes = [
      NSForegroundColorAttributeName : self.defaultTextColor()
    ]
    
    let pageControlAppearance = UIPageControl.appearance()
    pageControlAppearance.currentPageIndicatorTintColor = self.colorNumber15()
    pageControlAppearance.pageIndicatorTintColor = self.colorNumber18()
  }
}

// MARK: - Colors
extension DefaultTheme {
  func colorNumber1() -> UIColor {
    return UIColor.bwFloralWhite
  }
  func colorNumber2() -> UIColor {
    return UIColor.bwWhiteLinen
  }
  func colorNumber3() -> UIColor {
    return UIColor.bwSerenade
  }
  func colorNumber4() -> UIColor {
    return UIColor.bwHitPink
  }
  func colorNumber5() -> UIColor {
    return UIColor.bwShalimar
  }
  func colorNumber6() -> UIColor {
    return UIColor.bwSelectiveYellow
  }
  func colorNumber7() -> UIColor {
    return UIColor.bwClearDay
  }
  func colorNumber8() -> UIColor {
    return UIColor.bwKeppel
  }
  func colorNumber9() -> UIColor {
    return UIColor.bwAliceBlue
  }
  func colorNumber10() -> UIColor {
    return UIColor.bwJordyBlue
  }
  func colorNumber11() -> UIColor {
    return UIColor.bwLavender
  }
  func colorNumber12() -> UIColor {
    return UIColor.bwDeluge
  }
  func colorNumber13() -> UIColor {
    return UIColor.bwEarth
  }
  func colorNumber14() -> UIColor {
    return UIColor.bwCupid
  }
  func colorNumber15() -> UIColor {
    return UIColor.bwNobel
  }
  func colorNumber16() -> UIColor {
    return UIColor.bwMalibu
  }
  func colorNumber17() -> UIColor {
    return UIColor.bwMariner
  }
  func colorNumber18() -> UIColor {
    return UIColor.bwGainsboro
  }
  func colorNumber19() -> UIColor {
    return UIColor.bwRuby
  }
  func colorNumber20() -> UIColor {
    return UIColor.bwNero
  }
  func colorNumber21() -> UIColor {
    return UIColor.bwLimeGreen
  }
  func colorNumber22() -> UIColor {
    return UIColor.bwOrange
  }
  func colorNumber23() -> UIColor {
    return UIColor.bwWhite
  }
  func colorNumber24() -> UIColor {
    return UIColor.bwSangria
  }
  
  func colorNumber19Highlighted() -> UIColor {
    return UIColor.bwRubyHighlighted
  }
  
  
  
  func defaultPrimaryButtonColor() -> UIColor {
    return colorNumber19()
  }
  
  func defaultPrimaryButtonHighlightedColor() -> UIColor {
    return colorNumber19Highlighted()
  }
  
  func defaultSecondaryButtonColor() -> UIColor {
    return colorNumber19()
  }
  
  func defaultSecondaryButtonHighlightedColor() -> UIColor {
    return colorNumber19Highlighted()
  }
  
  
  
  func defaultTextColor() -> UIColor {
    return colorNumber20()
  }
  
  func defaultGrayedTextColor() -> UIColor {
    return colorNumber15()
  }
  
  
  func defaultSeparatorColor() -> UIColor {
    return colorNumber18()
  }
  
  func defaultErrorColor() -> UIColor {
    return colorNumber24()
  }
}

// MARK: - Buttons
extension DefaultTheme {
  func stylePrimaryButton(button: UIButton) {
    stylePrimaryButton(
      button: button,
      withColor: defaultPrimaryButtonColor(),
      highlightedColor: defaultPrimaryButtonHighlightedColor())
  }
  
  func styleSecondaryButton(button: UIButton) {
    styleSecondaryButton(
      button: button,
      withColor: defaultSecondaryButtonColor(),
      highlightedColor: defaultSecondaryButtonHighlightedColor())
  }
  
  func stylePrimaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor) {
    button.setTitleColor(colorNumber23(), for: .normal)
    button.setTitleColor(colorNumber23(), for: UIControlState.highlighted)
    button.setBackgroundImage(UIImage(color: color), for: .normal)
    button.setBackgroundImage(UIImage(color: highlightedColor), for: .highlighted)
    button.clipsToBounds = true
    button.layer.cornerRadius = 4
  }
  
  func styleSecondaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor) {
    button.setTitleColor(color, for: .normal)
    button.setTitleColor(highlightedColor, for: .highlighted)
    button.backgroundColor = colorNumber23()
    button.clipsToBounds = true
    button.layer.cornerRadius = 4
    button.layer.borderWidth = 2
    button.layer.borderColor = color.cgColor
  }
}

// MARK: - Labels
extension DefaultTheme {
  func styleLabel(label: UILabel) {
    label.font = FontDynamicType.label.font
    label.textColor = defaultTextColor()
  }

  func styleCaption(label: UILabel, color: UIColor) {
    label.textColor = color
    label.font = FontDynamicType.caption2.font
  }
}

// MARK: - Text Fields
extension DefaultTheme {
  func styleTextField(textField: UITextField) {
    textField.font = FontDynamicType.subheadline.font
    textField.textColor = defaultTextColor()
    textField.borderStyle = UITextBorderStyle.none
  }
}

// MARK - TTT Attributed Labels
extension DefaultTheme {
  func styleTextLinkAttributes() -> [AnyHashable : Any] {
    return [
      NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue,
      NSForegroundColorAttributeName : ThemeManager.shared.currentTheme.colorNumber19()
    ]
  }
}
