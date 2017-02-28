//
//  IntroductionViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class IntroductionViewModel {
  let tutorialData: [TutorialPageData] = [
    (title: Strings.tutorial_first_page_title(), Strings.tutorial_first_page_title(),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber4()),
    (title: Strings.tutorial_second_page_title(),
     description: Strings.tutorial_second_page_description(),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: Strings.tutorial_third_page_title(),
     description: Strings.tutorial_second_page_description(),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: Strings.tutorial_forth_page_title(),
     description: Strings.tutorial_forth_page_description(),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: Strings.tutorial_fifth_page_title(),
     description: Strings.tutorial_fifth_page_description(),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6())
  ]
  
  let signInButtonTitle: String = Strings.sign_in()
  let registerButtonTitle: String = Strings.register()
  
  func colorForIndex(index: Int) -> UIColor? {
    return tutorialData[index].color
  }
}
