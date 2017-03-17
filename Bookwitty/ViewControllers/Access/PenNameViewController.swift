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
      textFieldPlaceholder: Strings.enter_your_pen_name(),
      invalidationErrorMessage: Strings.pen_name_cant_be_empty(),
      returnKeyType: UIReturnKeyType.done)
    
    self.title = Strings.choose_pen_name()
    continueButton.setTitle(Strings.continue(), for: .normal)
    penNameLabel.text = Strings.pen_name()
    noteLabel.text = Strings.dont_worry_you_can_change_it_later()
    penNameInputField.textField.text  = viewModel.penDisplayName()

    penNameInputField.validationBlock = notEmptyValidation

    penNameInputField.delegate = self

    setupBiographyKeyboardToolbar()

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
    
    // TODO: remove the following line
    profileContainerView.isHidden = true
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
    // Set the show pen name flag to false
    UserManager.shared.shouldEditPenName = false
    
    // Hide keyboard if visible
    _ = penNameInputField.resignFirstResponder()
    _ = biographyTextView.resignFirstResponder()

    let name = penNameInputField.textField.text
    let biography = biographyTextView.text
    self.viewModel.updatePenNameIfNeeded(name: name, biography: biography) {
      (success: Bool) in
      // TODO: Handle the fail here
      self.pushOnboardingViewController()
    }
  }
  
  fileprivate func pushOnboardingViewController() {
    let onboardingViewController = OnBoardingViewController()
    navigationController?.pushViewController(onboardingViewController, animated: true)
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

    let alertController = UIAlertController(title: Strings.profile_picture(), message: nil, preferredStyle: .actionSheet)
    let chooseFromLibraryButton = UIAlertAction(title: Strings.choose_from_library(), style: .default, handler: { (action) -> Void in
      self.openLibrary()
    })
    let  takeAPhotoButton = UIAlertAction(title: Strings.take_Profile_photo(), style: .default, handler: { (action) -> Void in
      self.openCamera()
    })
    let  removePhotoButton = UIAlertAction(title: Strings.clear_profile_photo(), style: .default, handler: { (action) -> Void in
      self.profileImageView.image = nil
      self.plusImageView.alpha = 1
    })

    let cancelButton = UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil)

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

  func setupBiographyKeyboardToolbar() {
    let keyboardToolBarHeight: CGFloat = 50.0
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: keyboardToolBarHeight))

    toolBar.barStyle = UIBarStyle.default
    toolBar.items = [
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(title: Strings.done(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(toolbarDoneButtonAction))]
    toolBar.sizeToFit()

    biographyTextView.inputAccessoryView = toolBar
  }

  func toolbarDoneButtonAction() {
    //Close keyboard when done button is pressed
    biographyTextView.resignFirstResponder()
  }
}

extension PenNameViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    switch inputField {
    case penNameInputField:
      return biographyTextView.becomeFirstResponder()
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

    //biographyTextView
  }

  func makeViewCircular(view: UIView,borderColor: UIColor, borderWidth: CGFloat) {
    view.layer.cornerRadius = view.frame.size.width/2
    view.clipsToBounds = true
    view.layer.borderColor = borderColor.cgColor
    view.layer.borderWidth = 1.0
  }
}
