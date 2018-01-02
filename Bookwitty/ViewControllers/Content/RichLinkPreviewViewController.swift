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

  fileprivate let viewModel = RichLinkPreviewViewModel()
  var mode: Mode = .link

  var delegate: RichLinkPreviewViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()
    addKeyboardNotifications()
    self.textView.becomeFirstResponder()
  }

  fileprivate func initializeComponents() {
    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGestureHandler(_:)))
    view.addGestureRecognizer(tapGesture)

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

    switch self.mode {
    case .link:
      title = Strings.link()
    case .video:
      title = Strings.video()
    case .audio:
      title = Strings.audio()
    }
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
    var attributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    attributes[NSForegroundColorAttributeName] = defaultTextColor
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
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()

    view.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    textView.textContainerInset = ThemeManager.shared.currentTheme.defaultLayoutMargin()

    separators.forEach({ $0.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()})

    //Link Preview
    linkPreview.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    linkPreview.layer.borderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor().cgColor
    linkPreview.layer.borderWidth = 1.0

    linkTitleLabel.font = FontDynamicType.title1.font
    linkDescriptionLabel.font = FontDynamicType.body.font
    linkHostLabel.font = FontDynamicType.caption2.font

    //Video Preview
    videoPreview.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    videoPreview.layer.borderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor().cgColor
    videoPreview.layer.borderWidth = 1.0
    videoPlayView.image = #imageLiteral(resourceName: "play")
    videoPlayView.tintColor = ThemeManager.shared.currentTheme.colorNumber23().withAlphaComponent(0.9)
    videoPlayView.contentMode = .scaleAspectFit
    videoTitleLabel.textColor = ThemeManager.shared.currentTheme.colorNumber23()
    videoDescriptionLabel.textColor = ThemeManager.shared.currentTheme.colorNumber23()
    videoHostLabel.textColor = ThemeManager.shared.currentTheme.colorNumber23()
    
    //Audio Preview
    audioPreview.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    audioPreview.layer.borderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor().cgColor
    audioPreview.layer.borderWidth = 1.0
    audioTitleLabel.font = FontDynamicType.title1.font
    audioDescriptionLabel.font = FontDynamicType.body.font
    audioHostLabel.font = FontDynamicType.caption2.font
    
    //Error Preview
    errorPreview.layer.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    errorPreview.layer.borderWidth = 1.0

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
    if let imageUrl = response.thumbnails?.first?.url {
      videoImageView.sd_setImage(with: imageUrl) { (image: UIImage?, _, _, _) in
        guard let image = image else {
          return
        }
        let ratio = self.videoImageView.frame.width / image.size.width
        let height = image.size.height * ratio
        self.videoPreviewHeightConstraint.constant = height
        self.contentHeightConstraint.constant = 5 + height + 5
        }
    } else {
      videoImageView.image = #imageLiteral(resourceName: "videoPlaceholder")
      videoImageView.tintColor = ThemeManager.shared.currentTheme.colorNumber15()
    }
    videoPreview.isHidden = false
  }

  fileprivate func fillAudioPreview(with response: Response) {
    if let imageUrl = response.thumbnails?.first?.url {
      audioImageView.sd_setImage(with: imageUrl)
      audioTitleLabel.text = response.title
      audioDescriptionLabel.text = response.shortDescription
      audioHostLabel.text = response.embedUrl?.host
    } else {
      audioImageView.image = #imageLiteral(resourceName: "audioPlaceholder")
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
