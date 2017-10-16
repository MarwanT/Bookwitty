//
//  PenNameViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import ALCameraViewController
import SwiftLoader

protocol PenNameViewControllerDelegate: class {
  func penName(viewController: PenNameViewController, didFinish: PenNameViewController.Mode, with penName: PenName?)
}

class PenNameViewController: UIViewController {

  enum Mode {
    case New
    case Edit
  }

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
  let defaultPenNameImageSize = CGSize(width: 600, height: 600)
  let viewModel: PenNameViewModel = PenNameViewModel()
  let maximumNumberOfPenNameCharacters: Int = 36
  var showNoteLabel: Bool = true
  var didEditImage: Bool = false
  var candidateImageId: String?
  var mode: Mode = .New

  weak var delegate: PenNameViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()
    applyLocalization()
    observeLanguageChanges()
    prefillData()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.EditPenName)
  }

  /// Do the required setup
  private func awakeSelf() {

    penNameInputField.validationBlock = notEmptyValidation

    penNameInputField.delegate = self

    setupBiographyKeyboardToolbar()
    
    noteLabel.isHidden = !showNoteLabel

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

  func prefillData() {
    penNameInputField.textField.text = viewModel.penDisplayName()
    biographyTextView.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.label)
      .append(text: viewModel.penBiography(), color: ThemeManager.shared.currentTheme.defaultTextColor())
      .attributedString
    if let avatarUrl = viewModel.penAvatarUrl(), let url = URL(string: avatarUrl) {
      self.profileImageView.sd_setImage(with: url)
      self.plusImageView.alpha = 0
    }
  }

  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    switch mode {
    case .New:
      createPenNameProfile()
    case .Edit:
      updateUserProfile()
    }
  }

  fileprivate func createPenNameProfile() {
    /**
     Upload the pen name image if needed before proceeding
     with completing the pen name profile creation
     */

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .EditPenName)
    Analytics.shared.send(event: event)

    showLoader()
    self.uploadUserImageIfNeeded { (imageId) in
      self.createPenName(imageId: imageId)
    }
  }

  fileprivate func createPenName(imageId: String?) {
    // Hide keyboard if visible
    _ = penNameInputField.resignFirstResponder()
    _ = biographyTextView.resignFirstResponder()

    guard let name = penNameInputField.textField.text, !name.isBlank else {
      self.hideLoader()
      showErrorUpdatingPasswordAlert(error: Strings.pen_name_cant_be_empty())
      return
    }
    guard penNameInputField.textField.text?.characters.count ?? 0 <= maximumNumberOfPenNameCharacters else {
      self.hideLoader()
      showErrorUpdatingPasswordAlert(error: Strings.pen_name_max_number_of_characters_thirty_six())
      return
    }

    let biography = biographyTextView.text

    self.viewModel.createPenName(name: name, biography: biography, avatarId: imageId) {
      (success: Bool, penName: PenName?, error: BookwittyAPIError?) in
      self.hideLoader()
      guard success, let penName = penName else {
        self.handleError(error: error)
        return
      }

      self.delegate?.penName(viewController: self, didFinish: self.mode, with: penName)
      _ = self.navigationController?.popViewController(animated: true)
    }
  }
  
  fileprivate func handleError(error: BookwittyAPIError?) {
    if let error = error {
      switch error {
      case .penNameHasAlreadyBeenTaken:
        showErrorUpdatingPasswordAlert(error: Strings.pen_name_error_was_already_taken())
      default:
        showErrorUpdatingPasswordAlert(error: Strings.pen_name_error_could_not_create())
      }
    }
  }

  fileprivate func showErrorUpdatingPasswordAlert(error message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Strings.ok(), style: .default, handler: nil))
    self.navigationController?.present(alert, animated: true, completion: nil)
  }

  fileprivate func updateUserProfile() {
    /**
     Upload the pen name image if needed before proceeding
     with completing the pen name profile update
     */
    showLoader()
    
    self.uploadUserImageIfNeeded { (imageId) in
      self.updatePenNameProfile(imageId: imageId, completion: { (success: Bool) in
        self.hideLoader()
        if success {
          self.delegate?.penName(viewController: self, didFinish: self.mode, with: self.viewModel.penName)
          if UserManager.shared.shouldDisplayOnboarding {
            self.pushOnboardingViewController()
          } else {
            _ = self.navigationController?.popViewController(animated: true)
          }
        }
      })
    }
  }
  
  fileprivate func uploadUserImageIfNeeded(completion: @escaping (_ imageId: String?)->()) {
    guard candidateImageId == nil else {
      completion(candidateImageId)
      return
    }

    guard didEditImage, let image = profileImageView.image else {
      completion(nil)
      return
    }
    
    viewModel.upload(image: image, completion: {
      (success, imageId) in
      self.didEditImage = false
      self.candidateImageId = imageId
      completion(imageId)
    })
  }
  
  
  fileprivate func updatePenNameProfile(imageId: String?, completion: @escaping (_ success: Bool) -> Void) {
    // Set the show pen name flag to false
    UserManager.shared.shouldEditPenName = false
    
    // Hide keyboard if visible
    _ = penNameInputField.resignFirstResponder()
    _ = biographyTextView.resignFirstResponder()

    guard let name = penNameInputField.textField.text, !name.isBlank else {
      completion(false)
      showErrorUpdatingPasswordAlert(error: Strings.pen_name_cant_be_empty())
      return
    }
    guard penNameInputField.textField.text?.characters.count ?? 0 <= maximumNumberOfPenNameCharacters else {
      completion(false)
      showErrorUpdatingPasswordAlert(error: Strings.pen_name_max_number_of_characters_thirty_six())
      return
    }
    let biography = biographyTextView.text
    
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .EditPenName)
    Analytics.shared.send(event: event)
    
    self.viewModel.updatePenNameIfNeeded(name: name, biography: biography, avatarId: imageId) {
      (success: Bool, error: BookwittyAPIError?) in
      if !success {
        self.handleError(error: error)
      }

      completion(success)
    }
  }
  
  fileprivate func pushOnboardingViewController() {
    let onboardingViewController = OnBoardingViewController()
    navigationController?.pushViewController(onboardingViewController, animated: true)
  }
  
  fileprivate func resized(_ image: UIImage?) -> UIImage? {
    guard let imageSize = image?.size, (imageSize.height > defaultPenNameImageSize.height || imageSize.width > defaultPenNameImageSize.width) else {
      return image
    }
    return image?.imageWithSize(size: defaultPenNameImageSize)
  }

  // MARK: - Keyboard Handling
  func keyboardWillShow(_ notification: NSNotification) {
    let heightToShowTextBox = profileContainerView.frame.height - 10.0 // The 10.0 is just to keep a part of the image visible

    topViewToTopConstraint.constant = -heightToShowTextBox
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
      self.candidateImageId = "" // Empty String makes the image deletable, nil => does not
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
      if let image = self?.resized(image) {
        self?.didEditImage = true
        self?.candidateImageId = nil
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
      if let image = self.resized(image) {
        self.didEditImage = true
        self.candidateImageId = nil
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
  
  // MARK: - Network indicator handling
  private func showLoader() {
    SwiftLoader.show(animated: true)
  }
  
  private func hideLoader() {
    SwiftLoader.hide()
  }
}

extension PenNameViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    switch inputField {
    case penNameInputField:
      _ = biographyTextView.becomeFirstResponder()
      return false
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
    penNameInputField.textField.textAlignment = .center
    penNameInputField.textField.font = FontDynamicType.callout.font
    
    penNameLabel.font = FontDynamicType.caption1.font
    penNameLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    noteLabel.font = FontDynamicType.caption1.font
    noteLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    biographyLabel.font = FontDynamicType.caption2.font
    biographyLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    
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

//MARK: - Localizable implementation
extension PenNameViewController: Localizable {
  func applyLocalization() {
    title = Strings.choose_pen_name()
    penNameInputField.configuration = InputFieldConfiguration(
      textFieldPlaceholder: Strings.enter_your_pen_name(),
      invalidationErrorMessage: Strings.pen_name_cant_be_empty(),
      returnKeyType: UIReturnKeyType.done)

    continueButton.setTitle(Strings.continue(), for: .normal)
    penNameLabel.text = Strings.pen_name()
    noteLabel.text = Strings.dont_worry_you_can_change_it_later()
    biographyLabel.text = Strings.biography()

    setupBiographyKeyboardToolbar()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
