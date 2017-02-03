//
//  PenNameViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PenNameViewController: UIViewController {
  @IBOutlet weak var circularView: UIView!
  @IBOutlet weak var plusImageView: UIImageView!
  @IBOutlet weak var penNameLabel: UILabel!
  @IBOutlet weak var noteLabel: UILabel!
  @IBOutlet weak var penNameInputField: InputField!
  @IBOutlet weak var continueButton: UIButton!

  @IBOutlet weak var topViewToTopConstraint: NSLayoutConstraint!
  let topViewToTopSpace: CGFloat = 40
  let viewModel: PenNameViewModel = PenNameViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()
  }

  /// Do the required setup
  private func awakeSelf() {
    self.title = viewModel.viewControllerTitle
    continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
    penNameLabel.text = viewModel.penNameTitleText
    noteLabel.text = viewModel.penNameNoteText
    penNameInputField.textField.text  = "Shafic Hariri"

    penNameInputField.configuration = InputFieldConfiguration(
      textFieldPlaceholder: viewModel.penNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.penNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue)

    penNameInputField.validationBlock = notEmptyValidation

    penNameInputField.delegate = self

    //Make Cicular View tappable
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnCircularView(_:)))
    circularView.addGestureRecognizer(tap)
    circularView.isUserInteractionEnabled = true
  }

  func notEmptyValidation(text: String?) -> Bool {
    return text?.isValidText() ?? false
  }

  func didTapOnCircularView(_ sender: UITapGestureRecognizer) {
    //TODO: action dialog to pick image or camera
  }

  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    //TODO: validate and action
  }
}

extension PenNameViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    switch inputField {
    case penNameInputField:
      return penNameInputField.resignFirstResponder()
    default: return true
    }
  }
}

extension PenNameViewController: Themeable {
  func applyTheme() {
    circularView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber11()
    makeViewCircular(view: circularView, borderColor: ThemeManager.shared.currentTheme.colorNumber18(), borderWidth: 1.0)

    plusImageView.image = UIImage(named: "plus-icon")
    plusImageView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()

    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: continueButton)
    ThemeManager.shared.currentTheme.styleLabel(label: penNameLabel)
    //TODO: replace caption with caption2 style
    ThemeManager.shared.currentTheme.styleCaption(label: noteLabel,
                                                color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    penNameInputField.textField.textAlignment = .center
  }

  func makeViewCircular(view: UIView,borderColor: UIColor, borderWidth: CGFloat) {
    view.layer.cornerRadius = view.frame.size.width/2
    view.clipsToBounds = true
    view.layer.borderColor = borderColor.cgColor
    view.layer.borderWidth = 1.0
  }
}
