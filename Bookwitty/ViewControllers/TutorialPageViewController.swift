//
//  IntroductionInformationViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var tutorialPageData: TutorialPageData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    fillContent()
  }
  
  private func fillContent() {
    titleLabel.text = tutorialPageData?.title
    descriptionLabel.text = tutorialPageData?.description
    imageView.image = tutorialPageData?.image
    imageView.backgroundColor = tutorialPageData?.color
  }
}
