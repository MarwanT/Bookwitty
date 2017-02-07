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
    (title: localizedString(key: "tutorial_first_page_title", defaultValue: "Empower Your Curiosity"),
     description: localizedString(
      key: "tutorial_first_page_description",
      defaultValue: " "),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber4()),
    (title: localizedString(key: "tutorial_second_page_title", defaultValue: "Discover Ideas & People"),
     description: localizedString(key: "tutorial_second_page_description", defaultValue: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like"),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: localizedString(key: "tutorial_third_page_title", defaultValue: "Share Your Own Ideas"),
     description: localizedString(key: "tutorial_second_page_description", defaultValue: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like"),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: localizedString(key: "tutorial_forth_page_title", defaultValue: "For The Love Of Books"),
     description: localizedString(key: "tutorial_forth_page_description", defaultValue: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like"),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: localizedString(key: "tutorial_fifth_page_title", defaultValue: "Join The Fun"),
     description: localizedString(key: "tutorial_fifth_page_description", defaultValue: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like"),
     image: #imageLiteral(resourceName: "Illustrtion"),
     color: ThemeManager.shared.currentTheme.colorNumber6())
  ]
  
  let signInButtonTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
  let registerButtonTitle: String = localizedString(key: "register", defaultValue: "Register")
  
  func colorForIndex(index: Int) -> UIColor? {
    return tutorialData[index].color
  }
}
