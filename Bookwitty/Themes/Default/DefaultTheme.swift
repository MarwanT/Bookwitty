//
//  DefaultTheme.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class DefaultTheme: Theme {
  func initialize() {
    // Initialize navigation bar and other stuff
    
    let appearance = UINavigationBar.appearance()
    appearance.barTintColor = self.colorNumber23()
    appearance.tintColor = self.colorNumber23()
    appearance.isTranslucent = false
    appearance.titleTextAttributes = [
      NSForegroundColorAttributeName : self.colorNumber20()
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
  
  func colorNumber19Highlighted() -> UIColor {
    return UIColor.bwRubyHighlighted
  }
}
