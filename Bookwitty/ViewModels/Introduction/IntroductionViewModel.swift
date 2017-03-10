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
     image: #imageLiteral(resourceName: "illustration1"),
     color: ThemeManager.shared.currentTheme.colorNumber19(),
     pastelColor: ThemeManager.shared.currentTheme.colorNumber2()),
    (title: Strings.tutorial_second_page_title(),
     description: Strings.tutorial_second_page_description(),
     image: #imageLiteral(resourceName: "illustration2"),
     color: ThemeManager.shared.currentTheme.colorNumber10(),
     pastelColor: ThemeManager.shared.currentTheme.colorNumber9()),
    (title: Strings.tutorial_third_page_title(),
     description: Strings.tutorial_second_page_description(),
     image: #imageLiteral(resourceName: "illustration3"),
     color: ThemeManager.shared.currentTheme.colorNumber4(),
     pastelColor: ThemeManager.shared.currentTheme.colorNumber3()),
    (title: Strings.tutorial_forth_page_title(),
     description: Strings.tutorial_forth_page_description(),
     image: #imageLiteral(resourceName: "illustration4"),
     color: ThemeManager.shared.currentTheme.colorNumber12(),
     pastelColor: ThemeManager.shared.currentTheme.colorNumber11()),
    (title: Strings.tutorial_fifth_page_title(),
     description: Strings.tutorial_fifth_page_description(),
     image: #imageLiteral(resourceName: "illustration5"),
     color: ThemeManager.shared.currentTheme.colorNumber8(),
     pastelColor: ThemeManager.shared.currentTheme.colorNumber7())
  ]
  
  let signInButtonTitle: String = Strings.sign_in()
  let registerButtonTitle: String = Strings.register()
  
  func colorsForIndex(index: Int) -> (color: UIColor?, pastelColor: UIColor?) {
    return (tutorialData[index].color, tutorialData[index].pastelColor)
  }
}
