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
    (title: "Empower Your Curiosity", description: nil, image: UIImage(), color: ThemeManager.shared.currentTheme.colorNumber4()),
    (title: "Discover Ideas & People", description: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like", image: UIImage(), color: ThemeManager.shared.currentTheme.colorNumber6()),
    (title: "Share Your Own Ideas", description: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like", image: UIImage(), color: ThemeManager.shared.currentTheme.colorNumber8()),
    (title: "For The Love Of Books", description: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like", image: UIImage(), color: ThemeManager.shared.currentTheme.colorNumber13()),
    (title: "Join The Fun", description: "Whatever you want to dig deeper in a topic, explore new ideas or discuss with people, you're sure to find articles and reading lists about subjects you like", image: UIImage(), color: ThemeManager.shared.currentTheme.colorNumber19()),
  ]
  
  let signInButtonTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
  let registerButtonTitle: String = localizedString(key: "register", defaultValue: "Register")
  
  func colorForIndex(index: Int) -> UIColor? {
    return tutorialData[index].color
  }
}
