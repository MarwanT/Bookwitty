//
//  PenNameViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import ALCameraViewController

class PenNameViewController: UIViewController {
  @IBOutlet weak var profileContainerView: UIView!
  @IBOutlet weak var plusImageView: UIImageView!
  @IBOutlet weak var penNameLabel: UILabel!
  @IBOutlet weak var noteLabel: UILabel!
  @IBOutlet weak var penNameInputField: InputField!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var profileImageView: UIImageView!

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
      returnKeyType: UIReturnKeyType.done)

    penNameInputField.validationBlock = notEmptyValidation

    penNameInputField.delegate = self

    //Make Cicular View tappable
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnCircularView(_:)))
    profileContainerView.addGestureRecognizer(tap)
    profileContainerView.isUserInteractionEnabled = true

    //Handle keyboard changes 
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(PenNameViewController.keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(PenNameViewController.keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func notEmptyValidation(text: String?) -> Bool {
    return text?.isValidText() ?? false
  }

  func didTapOnCircularView(_ sender: UITapGestureRecognizer) {
    //Hide keyboard if visible
    _ = penNameInputField.resignFirstResponder()
    showPhotoPickerActionSheet()
  }

  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    //Hide keyboard if visible
    _ = penNameInputField.resignFirstResponder()
    //TODO: validate and action
  }

  // MARK: - Keyboard Handling
  func keyboardWillShow(_ notification: NSNotification) {
    topViewToTopConstraint.constant = -profileContainerView.frame.height/2
    profileContainerView.alpha = 0.2
    UIView.animate(withDuration: 0.44) {
      self.view.layoutIfNeeded()
    }
  }

  func keyboardWillHide(_ notification: NSNotification) {
    topViewToTopConstraint.constant = topViewToTopSpace
    profileContainerView.alpha = 1
    UIView.animate(withDuration: 0.44) {
      self.view.layoutIfNeeded()
    }
  }

  func showPhotoPickerActionSheet() {
    let alertController = UIAlertController(title: viewModel.imagePickerTitle, message: nil, preferredStyle: .actionSheet)
    let sendButton = UIAlertAction(title: viewModel.chooseFromLibraryText, style: .default, handler: { (action) -> Void in
      self.openLibrary()
    })
    let  deleteButton = UIAlertAction(title: viewModel.takeProfilePhotoText, style: .default, handler: { (action) -> Void in
      self.openCamera()
    })
    let cancelButton = UIAlertAction(title: viewModel.cancelText, style: .cancel, handler: nil)

    alertController.addAction(sendButton)
    alertController.addAction(deleteButton)
    alertController.addAction(cancelButton)

    self.show(alertController, sender: self)
  }

  func openCamera() {
    let croppingEnabled = true
    let libraryEnabled = false
    let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
      if let image = image {
        self?.profileImageView.image = image
        self?.plusImageView.alpha = 0
      }
      self?.dismiss(animated: true, completion: nil)
    }
    cameraViewController.view.backgroundColor = UIColor.white
    present(cameraViewController, animated: true, completion: nil)
  }

  func openLibrary() {
    let croppingEnabled = true
    let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: croppingEnabled) { image, asset in
      if let image = image {
        self.profileImageView.image = image
        self.plusImageView.alpha = 0
      }
      self.dismiss(animated: true, completion: nil)
    }
    libraryViewController.view.backgroundColor = UIColor.white
    present(libraryViewController, animated: true, completion: nil)
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
    profileImageView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber11()
    makeViewCircular(view: profileImageView, borderColor: ThemeManager.shared.currentTheme.colorNumber18(), borderWidth: 1.0)

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
