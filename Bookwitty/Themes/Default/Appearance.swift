//
//  Appearance.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import TTTAttributedLabel
import AsyncDisplayKit

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
  func colorNumber24() -> UIColor
  func colorNumber25() -> UIColor
  
  func colorNumber19Highlighted() -> UIColor
  func colorNumber22Highlighted() -> UIColor
  
  func defaultErrorColor() -> UIColor
  
  func defaultECommerceColor() -> UIColor
  
  func defaultButtonColor() -> UIColor
  func defaultButtonHighlightedColor() -> UIColor
  func defaultEcommerceButtonColor() -> UIColor
  func defaultEcommerceButtonHighlightedColor() -> UIColor
  
  func defaultTextColor() -> UIColor
  func defaultGrayedTextColor() -> UIColor
  
  func defaultSeparatorColor() -> UIColor
  
  func defaultSelectionColor() -> UIColor
  
  func defaultBackgroundColor() -> UIColor
}

protocol ThemeSpacing {
  func defaultLayoutMargin() -> UIEdgeInsets
  func defaultTextViewInsets() -> UIEdgeInsets
  func cardExternalMargin() -> CGFloat
  func witItButtonMargin() -> CGFloat
  func cardInternalMargin() -> CGFloat
  func titleMargin() -> CGFloat
  func generalExternalMargin() -> CGFloat
  func contentSpacing() -> CGFloat
  func reviewsSectionSpacing() -> CGFloat
  func booksVerticalSpacing() -> CGFloat
  func sectionSpacing() -> CGFloat
}

protocol ThemeButtonsStyle {
  func stylePrimaryButton(button: UIButton)
  func styleSecondaryButton(button: UIButton)
  func styleECommercePrimaryButton(button: UIButton)
  func styleECommerceSecondaryButton(button: UIButton)
  func stylePrimaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor)
  func styleSecondaryButton(button: UIButton, withColor color: UIColor, highlightedColor: UIColor)
  
  func stylePrimaryButton(button: ASButtonNode)
  func styleSecondaryButton(button: ASButtonNode)
  func styleECommercePrimaryButton(button: ASButtonNode)
  func styleECommerceSecondaryButton(button: ASButtonNode)
  func stylePrimaryButton(button: ASButtonNode, withColor color: UIColor, highlightedColor: UIColor)
  func styleSecondaryButton(button: ASButtonNode, withColor color: UIColor, highlightedColor: UIColor)
  func styleFlat(button: ASButtonNode)
}

// TODO: Needs to be revised
protocol ThemeLabelsStyle {
  func styleCallout(label: UILabel)
  func styleCaption1(label: UILabel)
  func styleCaption2(label: UILabel)
  func styleLabel(label: UILabel)
}

protocol ThemeTextFieldsStyle {
  func styleTextField(textField: UITextField)
}

protocol ThemeAttributedTextStyle {
  func styleTextLinkAttributes() -> [AnyHashable : Any]
}

protocol ThemeImageStyling {
  var penNamePlaceholder: UIImage { get }
}

protocol Theme: ThemeSpacing, ThemeColor, ThemeButtonsStyle, ThemeLabelsStyle, ThemeTextFieldsStyle, ThemeAttributedTextStyle, ThemeImageStyling {
  func initialize()
  
  func defaultCornerRadius() -> CGFloat
}

class ThemeManager {
  static let shared = ThemeManager()
  
  var currentTheme: Theme {
    didSet{
      // TODO: Send notification for updating the layout throughout the app
    }
  }
  
  private init() {
    currentTheme = DefaultTheme()
  }
}
