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
  @IBOutlet weak var biographyTextView: UITextView!
  @IBOutlet weak var biographyLabel: UILabel!

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
    penNameInputField.configuration = InputFieldConfiguration(
      textFieldPlaceholder: viewModel.penNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.penNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.done)
    
    self.title = viewModel.viewControllerTitle
    continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
    penNameLabel.text = viewModel.penNameTitleText
    noteLabel.text = viewModel.penNameNoteText
    penNameInputField.textField.text  = viewModel.penDisplayName()

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
    let hasProfilePicture = self.profileImageView.image != nil

    let alertController = UIAlertController(title: viewModel.imagePickerTitle, message: nil, preferredStyle: .actionSheet)
    let chooseFromLibraryButton = UIAlertAction(title: viewModel.chooseFromLibraryText, style: .default, handler: { (action) -> Void in
      self.openLibrary()
    })
    let  takeAPhotoButton = UIAlertAction(title: viewModel.takeProfilePhotoText, style: .default, handler: { (action) -> Void in
      self.openCamera()
    })
    let  removePhotoButton = UIAlertAction(title: viewModel.removeProfilePhotoText, style: .default, handler: { (action) -> Void in
      self.profileImageView.image = nil
      self.plusImageView.alpha = 1
    })

    let cancelButton = UIAlertAction(title: viewModel.cancelText, style: .cancel, handler: nil)

    alertController.addAction(chooseFromLibraryButton)
    alertController.addAction(takeAPhotoButton)
    if(hasProfilePicture) {
      alertController.addAction(removePhotoButton)
    }
    alertController.addAction(cancelButton)

    navigationController?.present(alertController, animated: true, completion: nil)
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
    navigationController?.present(cameraViewController, animated: true, completion: nil)
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
    navigationController?.present(libraryViewController, animated: true, completion: nil)
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

    plusImageView.image = #imageLiteral(resourceName: "plus")
    plusImageView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()

    biographyTextView.layer.borderWidth = 1.0
    biographyTextView.layer.borderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor().cgColor
    biographyTextView.layer.cornerRadius = 4.0

    self.view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: continueButton)
    ThemeManager.shared.currentTheme.styleLabel(label: penNameLabel)
    ThemeManager.shared.currentTheme.styleCaption2(label: noteLabel)
    penNameInputField.textField.textAlignment = .center

    ThemeManager.shared.currentTheme.styleLabel(label: biographyLabel)
    biographyTextView.attributedText = AttributedStringBuilder.init(fontDynamicType: FontDynamicType.label).append(text: "", color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString

    noteLabel.textColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
  }

  func makeViewCircular(view: UIView,borderColor: UIColor, borderWidth: CGFloat) {
    view.layer.cornerRadius = view.frame.size.width/2
    view.clipsToBounds = true
    view.layer.borderColor = borderColor.cgColor
    view.layer.borderWidth = 1.0
  }
}
