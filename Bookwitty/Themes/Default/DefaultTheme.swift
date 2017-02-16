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
      NSFontAttributeName: FontDynamicType.subheadline.font,
      NSForegroundColorAttributeName : self.defaultTextColor()
    ]
    
    let pageControlAppearance = UIPageControl.appearance()
    pageControlAppearance.currentPageIndicatorTintColor = self.colorNumber15()
    pageControlAppearance.pageIndicatorTintColor = self.colorNumber18()

    UITabBar.appearance().barTintColor = self.colorNumber23()
    UITabBar.appearance().tintColor = self.colorNumber19()
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
  
  func colorNumber22Highlighted() -> UIColor {
    return UIColor.bwRubyHighlighted
  }
  
  
  
  func defaultButtonColor() -> UIColor {
    return colorNumber19()
  }
  
  func defaultButtonHighlightedColor() -> UIColor {
    return colorNumber19Highlighted()
  }
  
  func defaultEcommerceButtonColor() -> UIColor {
    return colorNumber22()
  }
  
  func defaultEcommerceButtonHighlightedColor() -> UIColor {
    return colorNumber22Highlighted()
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
  
  
  func defaultSelectionColor() -> UIColor {
    return colorNumber18()
  }
  
  func defaultBackgroundColor() -> UIColor {
    return colorNumber23()
  }
}

// MARK: - Buttons
extension DefaultTheme {
  func cardExternalMargin() -> CGFloat {
    return 10
  }
  
  func witItButtonMargin() -> CGFloat {
    return 12
  }
  
  func cardInternalMargin() -> CGFloat {
    return 15
  }
  
  func titleMargin() -> CGFloat {
    return 15
  }
  
  func generalExternalMargin() -> CGFloat {
    return 19
  }
  
  func contentSpacing() -> CGFloat {
    return 20
  }
  
  func reviewsSectionSpacing() -> CGFloat {
    return 25
  }
  
  func booksVerticalSpacing() -> CGFloat {
    return 30
  }
  
  func sectionSpacing() -> CGFloat {
    return 40
  }
}

// MARK: - Buttons
extension DefaultTheme {
  func stylePrimaryButton(button: UIButton) {
    stylePrimaryButton(
      button: button,
      withColor: defaultButtonColor(),
      highlightedColor: defaultButtonHighlightedColor())
  }
  
  func styleSecondaryButton(button: UIButton) {
    styleSecondaryButton(
      button: button,
      withColor: defaultButtonColor(),
      highlightedColor: defaultButtonHighlightedColor())
  }
  
  func stylePrimaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor) {
    button.titleLabel?.font = FontDynamicType.subheadline.font
    button.setTitleColor(colorNumber23(), for: .normal)
    button.setTitleColor(colorNumber23(), for: UIControlState.highlighted)
    button.setBackgroundImage(UIImage(color: color), for: .normal)
    button.setBackgroundImage(UIImage(color: highlightedColor), for: .highlighted)
    button.clipsToBounds = true
    button.layer.cornerRadius = 4
  }
  
  func styleSecondaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor) {
    button.titleLabel?.font = FontDynamicType.subheadline.font
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
  func styleCallout(label: UILabel) {
    label.font = FontDynamicType.callout.font
    label.textColor = defaultTextColor()
  }
  
  func styleCaption1(label: UILabel) {
    label.font = FontDynamicType.caption1.font
    label.textColor = defaultTextColor()
  }
  
  func styleCaption2(label: UILabel) {
    label.font = FontDynamicType.caption2.font
    label.textColor = defaultTextColor()
  }
  
  func styleLabel(label: UILabel) {
    label.font = FontDynamicType.label.font
    label.textColor = defaultTextColor()
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
