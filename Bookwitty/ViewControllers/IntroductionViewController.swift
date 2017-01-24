//
//  IntroductionViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {
  let viewModel = IntroductionViewModel()
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var tutorialContainer: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tutorialViewController = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
    tutorialViewController.viewModel.tutorialPageData = viewModel.tutorialData
    let tutorialChildView = add(asChildViewController: tutorialViewController, toView: tutorialContainer)
  }
  
  // MARK: - Actions
  @IBAction func registerButtonTap(_ sender: UIButton) {
  }
  
  @IBAction func signInButtonTap(_ sender: UIButton) {
  }
}
