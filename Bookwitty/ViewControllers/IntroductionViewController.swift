//
//  IntroductionViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

class IntroductionViewController: UIViewController {
  let viewModel = IntroductionViewModel()
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var tutorialContainer: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tutorialViewController = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
    tutorialViewController.tutorialDelegate = self
    tutorialViewController.viewModel.tutorialPageData = viewModel.tutorialData
    let tutorialChildView = add(asChildViewController: tutorialViewController, toView: tutorialContainer)
    tutorialChildView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: tutorialChildView.superview!)
    
    applyTheme()
  }
  
  
  // MARK: - Actions
  
  @IBAction func registerButtonTap(_ sender: UIButton) {
  }
  
  @IBAction func signInButtonTap(_ sender: UIButton) {
  }
}

extension IntroductionViewController: TutorialViewControllerDelegate {
  func tutorialViewController(_ tutorialViewController: TutorialViewController, didSelectPageAtIndex index: Int) {
  }
}

extension IntroductionViewController: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: signInButton)
    ThemeManager.shared.currentTheme.styleSecondaryButton(button: registerButton)
  }
}
