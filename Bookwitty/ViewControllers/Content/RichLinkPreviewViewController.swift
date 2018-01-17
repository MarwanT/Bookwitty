//
//  RichLinkPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol RichLinkPreviewViewControllerDelegate {
  func richLinkPreview(viewController: RichLinkPreviewViewController, didRequestLinkAdd: URL, with response: Response)
  func richLinkPreviewViewControllerDidCancel(_ viewController: RichLinkPreviewViewController)
}

class RichLinkPreviewViewController: UIViewController {

  enum Mode {
    case link
    case video
    case audio
    
    var placeholderText: String {
      switch self {
      case .audio:
        return Strings.audio_link() + " (" + Strings.type_or_paste_url() + ")"
      case .link:
        return Strings.link() + " (" + Strings.type_or_paste_url() + ")"
      case .video:
        return Strings.video_link() + " (" + Strings.type_or_paste_url() + ")"
      }
    }
  }

  @IBOutlet var scrollView: UIScrollView!

  @IBOutlet var textView: UITextView!
  @IBOutlet var separators: [UIView]!

  //Content Preview
  @IBOutlet var contentHeightConstraint: NSLayoutConstraint!

  //Link Preview
  @IBOutlet var linkPreview: UIView!
  @IBOutlet var linkTitleLabel: UILabel!
  @IBOutlet var linkDescriptionLabel: UILabel!
  @IBOutlet var linkHostLabel: UILabel!

  //Video Preview
  @IBOutlet var videoPreview: UIView!
  @IBOutlet var videoPlayView: UIImageView!
  @IBOutlet var videoImageView: UIImageView!
  @IBOutlet var videoPreviewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var videoTitleLabel: UILabel!
  @IBOutlet weak var videoDescriptionLabel: UILabel!
  @IBOutlet weak var videoHostLabel: UILabel!
  
  //Audio Preview
  @IBOutlet var audioPreview: UIView!
  @IBOutlet var audioImageView: UIImageView!
  @IBOutlet var audioTitleLabel: UILabel!
  @IBOutlet var audioDescriptionLabel: UILabel!
  @IBOutlet var audioHostLabel: UILabel!

  //Error Preview
  @IBOutlet var errorPreview: UIView!
  @IBOutlet var errorLabel: UILabel!

  @IBOutlet var scrollViewBottomLayoutConstraint: NSLayoutConstraint!
  
  fileprivate let textViewPlaceholderLabel = UILabel()

  fileprivate let viewModel = RichLinkPreviewViewModel()
  var mode: Mode = .link

  var delegate: RichLinkPreviewViewControllerDelegate?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyLocalization()
    applyTheme()
    setupNavigationBarButtons()
    addKeyboardNotifications()
    observeLanguageChanges()
    self.textView.becomeFirstResponder()
  }
  
  override func updateViewConstraints() {
    let insets = textView.textContainerInset
    textViewPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    textViewPlaceholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: insets.top).isActive = true
    textViewPlaceholderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: insets.left + 5).isActive = true
    super.updateViewConstraints()
  }

  fileprivate func initializeComponents() {
    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGestureHandler(_:)))
    view.addGestureRecognizer(tapGesture)
    
    textView.addSubview(textViewPlaceholderLabel)

    linkPreview.isHidden = true
    linkTitleLabel.text = nil
    linkDescriptionLabel.text = nil
    linkHostLabel.text = nil

    videoPreview.isHidden = true
    videoImageView.isUserInteractionEnabled = false
    videoPlayView.isUserInteractionEnabled = false
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(playVideoTapGestureHandler(_:)))
    videoPreview.addGestureRecognizer(tapGesture)

    audioPreview.isHidden = true
    audioTitleLabel.text = nil
    audioDescriptionLabel.text = nil
    audioHostLabel.text = nil

    errorPreview.isHidden = true
    errorLabel.text = nil

    viewModel.response = nil
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    let cancelBarButtonItem = UIBarButtonItem(title: Strings.cancel(),
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelBarButtonTouchUpInside(_:)))

    let addBarButtonItem = UIBarButtonItem(title: Strings.add(),
                                           style: .plain,
                                           target: self,
                                           action: #selector(addBarButtonTouchUpInside(_:)))

    addBarButtonItem.isEnabled = viewModel.response != nil

    navigationItem.leftBarButtonItem = cancelBarButtonItem
    navigationItem.rightBarButtonItem = addBarButtonItem

    setTextAppearanceState(of: addBarButtonItem)
    setTextAppearanceState(of: cancelBarButtonItem)
  }

  fileprivate func setTextAppearanceState(of barButtonItem: UIBarButtonItem) -> Void {
    let theme = ThemeManager.shared.currentTheme
    let defaultColor = theme.colorNumber20()
    let defaultActionColor = theme.defaultButtonColor()
    
    let isActionButton = barButtonItem === navigationItem.rightBarButtonItem
    var attributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]
    let defaultTextColor = isActionButton ? defaultActionColor : defaultColor
    attributes[NSForegroundColorAttributeName] = defaultTextColor
    if isActionButton {
      attributes[NSFontAttributeName] = FontDynamicType.footnote.font
    }
    barButtonItem.setTitleTextAttributes(attributes, for: .normal)

    let grayedTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    attributes[NSForegroundColorAttributeName] = grayedTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .disabled)
  }

  @objc fileprivate func cancelBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    delegate?.richLinkPreviewViewControllerDidCancel(self)
  }

  @objc fileprivate func addBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    guard let response = viewModel.response,
    let url = URL(string: textView.text) else {
      return
    }
    delegate?.richLinkPreview(viewController: self, didRequestLinkAdd: url, with: response)
  }
}

//MARK: - Themable implementation
extension RichLinkPreviewViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    
    view.backgroundColor = theme.colorNumber2()

    view.layoutMargins = theme.defaultLayoutMargin()
    
    textView.textContainerInset = theme.defaultLayoutMargin()
    textView.textColor = theme.defaultTextColor()
    textView.font = FontDynamicType.caption1.font

    textViewPlaceholderLabel.font = FontDynamicType.caption1.font
    textViewPlaceholderLabel.textColor = theme.defaultGrayedTextColor()

    separators.forEach({ $0.backgroundColor = theme.defaultSeparatorColor()})

    //Link Preview
    linkPreview.layoutMargins = theme.defaultLayoutMargin()
    linkPreview.layer.borderColor = theme.defaultSeparatorColor().cgColor
    linkPreview.layer.borderWidth = 1.0

    linkTitleLabel.font = FontDynamicType.title4.font
    linkDescriptionLabel.font = FontDynamicType.body2.font
    linkHostLabel.font = FontDynamicType.caption2.font
    linkTitleLabel.textColor = theme.defaultTextColor()
    linkDescriptionLabel.textColor = theme.defaultTextColor()
    linkHostLabel.textColor = theme.defaultTextColor()

    //Video Preview
    videoPreview.layoutMargins = theme.defaultLayoutMargin()
    videoPreview.layer.borderColor = theme.defaultSeparatorColor().cgColor
    videoPreview.layer.borderWidth = 1.0
    videoPlayView.image = #imageLiteral(resourceName: "play")
    videoPlayView.tintColor = theme.colorNumber23().withAlphaComponent(0.9)
    videoPlayView.contentMode = .scaleAspectFit
    videoTitleLabel.textColor = theme.colorNumber23()
    videoDescriptionLabel.textColor = theme.colorNumber23()
    videoHostLabel.textColor = theme.colorNumber23()
    
    //Audio Preview
    audioPreview.layoutMargins = theme.defaultLayoutMargin()
    audioPreview.layer.borderColor = theme.defaultSeparatorColor().cgColor
    audioPreview.layer.borderWidth = 1.0
    audioTitleLabel.font = FontDynamicType.title1.font
    audioDescriptionLabel.font = FontDynamicType.body.font
    audioHostLabel.font = FontDynamicType.caption2.font
    
    //Error Preview
    errorPreview.layer.borderColor = theme.defaultButtonColor().cgColor
    errorPreview.layer.borderWidth = 1.0

  }
}

//MARK: - Localizable implementation
extension RichLinkPreviewViewController: Localizable {
  func applyLocalization() {
    switch self.mode {
    case .link:
      title = Strings.link()
    case .video:
      title = Strings.video()
    case .audio:
      title = Strings.audio()
    }
    
    textViewPlaceholderLabel.text = self.mode.placeholderText
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

//MARK: - URL Handling
extension RichLinkPreviewViewController {
  @objc fileprivate func getUrlInfo() {
    //re-initilize components
    initializeComponents()
    setupNavigationBarButtons()
    
    guard !textView.text.isEmpty else {
      return
    }

    guard let url = URL(string: textView.text) else {
      fillError()
      return
    }

    IFramely.shared.loadResponseFor(url: url, closure: { (success: Bool, response: Response?) in
      defer {
        DispatchQueue.main.async {
          self.showLinkPreview()
          self.fillError()
          self.setupNavigationBarButtons()
        }
      }

      guard response?.html != nil else {
        self.viewModel.response = nil
        return
      }

      switch self.mode {
      case .video where response?.medias == nil: fallthrough
      case .audio where response?.medias == nil:
        self.viewModel.response = nil
        return
      default:
        break
      }

      self.viewModel.response = response
    })
  }

  fileprivate func showLinkPreview() {
    guard let response = viewModel.response else {
      return
    }

    switch mode {
    case .link:
      fillLinkPreview(with: response)
    case .video:
      fillVideoPreview(with: response)
    case .audio:
      fillAudioPreview(with: response)
    }
  }

  fileprivate func fillLinkPreview(with response: Response) {
    linkTitleLabel.text = response.title
    linkDescriptionLabel.text = response.shortDescription
    linkHostLabel.text = response.embedUrl?.host

    linkPreview.isHidden = false
  }

  fileprivate func fillVideoPreview(with response: Response) {
    
    func imageIsNotAvailable() {
      videoImageView.image = #imageLiteral(resourceName: "videoPlaceholder")
      videoImageView.tintColor = ThemeManager.shared.currentTheme.colorNumber15()
      videoImageView.contentMode = .scaleAspectFill
      videoPlayView.isHidden = true
      videoPreview.isHidden = false
    }
    
    if let imageUrl = response.thumbnails?.first?.url {
      
      videoImageView.sd_setImage(with: imageUrl) { [weak videoPlayView] (image: UIImage?, _, _, _) in
        guard let _ = image else {
          imageIsNotAvailable()
          return
        }
        videoPlayView?.isHidden = false
      }
    } else {
      imageIsNotAvailable()
    }
    videoTitleLabel.text = response.title
    videoDescriptionLabel.text = response.shortDescription
    videoHostLabel.text = response.site
    videoPreview.isHidden = false
  }

  fileprivate func fillAudioPreview(with response: Response) {
    
    func imageIsNotAvailable() {
      audioImageView.image = #imageLiteral(resourceName: "audioPlaceholder")
    }
    
    if let imageUrl = response.thumbnails?.first?.url {
      audioImageView.sd_setImage(with: imageUrl) { (image: UIImage?, _, _, _) in
        guard let _ = image else {
          imageIsNotAvailable()
          return
        }
      }
      audioTitleLabel.text = response.title
      audioDescriptionLabel.text = response.shortDescription
      audioHostLabel.text = response.embedUrl?.host
    } else {
      imageIsNotAvailable()
    }
    
    audioPreview.isHidden = false
  }

  fileprivate func fillError() {
    guard viewModel.response == nil else {
      return
    }

    errorLabel.text = Strings.invalid_url()
    errorPreview.isHidden = false
  }
}

//MARK: - Error handling
extension RichLinkPreviewViewController {
  fileprivate func showInvalidUrlAlert() {
    let alertController = UIAlertController(title: Strings.error(), message: Strings.invalid_url(), preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }

  fileprivate func showTryAgainAlert() {
    let alertController = UIAlertController(title: Strings.ooops(), message: Strings.some_thing_wrong_error(), preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: Strings.try_again(), style: .cancel, handler: {
      (action: UIAlertAction) in
      self.getUrlInfo()
    }))
    self.present(alertController, animated: true, completion: nil)
  }
}

//MARK: - Gestures
extension RichLinkPreviewViewController {
  @objc fileprivate func viewTapGestureHandler(_ sender: UITapGestureRecognizer) {
    if textView.isFirstResponder {
      textView.resignFirstResponder()
    }
  }

  @objc fileprivate func playVideoTapGestureHandler(_ sender: UITapGestureRecognizer) {
    guard let response = viewModel.response,
    let videoUrl = response.embedUrl else {
      return
    }

    WebViewController.present(url: videoUrl, inViewController: self)
  }
}

extension RichLinkPreviewViewController: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    textView.isScrollEnabled = false
    return true
  }

  public func textViewDidChange(_ textView: UITextView) {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    self.perform(#selector(getUrlInfo), with: nil, afterDelay: 0.5)

    self.perform(#selector(setTextViewScrollEnabled), with: nil, afterDelay: 0.02)
    
    let count = textView.text.count
    let alpha: CGFloat = count == 0 ? 1.0 : 0.0
    textViewPlaceholderLabel.alpha = alpha
  }

  @objc fileprivate func setTextViewScrollEnabled() {
    textView.isScrollEnabled = textView.intrinsicContentSize.height > textView.frame.height
  }
}

extension RichLinkPreviewViewController {
  fileprivate func addKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  // MARK: - Keyboard Handling
  func keyboardWillShow(_ notification: NSNotification) {
    if let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let frame = value.cgRectValue
      scrollViewBottomLayoutConstraint.constant = frame.height
      self.view.setNeedsUpdateConstraints()
    }
  }

  func keyboardWillHide(_ notification: NSNotification) {
    scrollViewBottomLayoutConstraint.constant = 0
    self.view.setNeedsUpdateConstraints()
  }
}
