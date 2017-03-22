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
    
    applyTheme()
    
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    fillContent()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }
  
  private func fillContent() {
    titleLabel.text = tutorialPageData?.title
    descriptionLabel.text = tutorialPageData?.description
    imageView.image = tutorialPageData?.image
    imageView.backgroundColor = tutorialPageData?.color
    
    if let descriptionText = descriptionLabel.text {
      let paragraStyle = NSMutableParagraphStyle()
      paragraStyle.lineSpacing = 5
      paragraStyle.alignment = .center
      let attrString = NSMutableAttributedString(
        string: descriptionText,
        attributes: [
          NSParagraphStyleAttributeName : paragraStyle
        ])
      descriptionLabel.attributedText = attrString
    }
  }
}

extension TutorialPageViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    ThemeManager.shared.currentTheme.styleCallout(label: titleLabel)
    ThemeManager.shared.currentTheme.styleCaption1(label: descriptionLabel)
    stackView.spacing = 10
  }
}
