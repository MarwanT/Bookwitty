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

  @IBOutlet var textView: UITextView!
  @IBOutlet var separators: [UIView]!

  //Link Preview
  @IBOutlet var linkPreview: UIView!
  @IBOutlet var linkTitleLabel: UILabel!
  @IBOutlet var linkDescriptionLabel: UILabel!
  @IBOutlet var linkHostLabel: UILabel!

  //Video Preview
  @IBOutlet var videoPreview: UIView!
  @IBOutlet var videoImageView: UIImageView!
  @IBOutlet var videoPreviewHeightConstraint: NSLayoutConstraint!

  //Audio Preview
  @IBOutlet var audioPreview: UIView!
  @IBOutlet var audioImageView: UIImageView!
  @IBOutlet var audioTitleLabel: UILabel!
  @IBOutlet var audioDescriptionLabel: UILabel!
  @IBOutlet var audioHostLabel: UILabel!

  fileprivate let viewModel = RichLinkPreviewViewModel()
  var mode: Mode = .link

  var delegate: RichLinkPreviewViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()
  }

  fileprivate func initializeComponents() {
    linkPreview.isHidden = true
    linkTitleLabel.text = nil
    linkDescriptionLabel.text = nil
    linkHostLabel.text = nil

    videoPreview.isHidden = true

    audioPreview.isHidden = true
    audioTitleLabel.text = nil
    audioDescriptionLabel.text = nil
    audioHostLabel.text = nil

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

    //Audio Preview
    audioPreview.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    audioPreview.layer.borderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor().cgColor
    audioPreview.layer.borderWidth = 1.0
    audioTitleLabel.font = FontDynamicType.title1.font
    audioDescriptionLabel.font = FontDynamicType.body.font
    audioHostLabel.font = FontDynamicType.caption2.font
  }
}

//MARK: - URL Handling
extension RichLinkPreviewViewController {
  fileprivate func getUrlInfo() {
    //re-initilize components
    initializeComponents()
    setupNavigationBarButtons()
    
    guard !textView.text.isEmpty, let url = URL(string: textView.text) else {
      return
    }

    IFramely.shared.loadResponseFor(url: url, closure: { (success: Bool, response: Response?) in
      defer {
        DispatchQueue.main.async {
          self.showLinkPreview()
          self.setupNavigationBarButtons()
        }
      }

      guard response?.embedUrl != nil else {
        self.viewModel.response = nil
        return
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
    let imageUrl = URL(string: response.thumbnails?.first?.url?.absoluteString ?? "")
    videoImageView.sd_setImage(with: imageUrl) { (image: UIImage?, _, _, _) in
      guard let image = image else {
        return
      }
      let ratio = self.videoImageView.frame.width / image.size.width
      let height = image.size.height * ratio
      self.videoPreviewHeightConstraint.constant = height
    }
    videoPreview.isHidden = false
  }

  fileprivate func fillAudioPreview(with response: Response) {
    let imageUrl = URL(string: response.thumbnails?.first?.url?.absoluteString ?? "")
    audioImageView.sd_setImage(with: imageUrl)
    audioTitleLabel.text = response.title
    audioDescriptionLabel.text = response.shortDescription
    audioHostLabel.text = response.embedUrl?.host

    audioPreview.isHidden = false
  }
}

extension RichLinkPreviewViewController: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    textView.isScrollEnabled = false
    return true
  }

  public func textViewDidChange(_ textView: UITextView) {
    getUrlInfo()

    let time: DispatchTime = DispatchTime.now() + DispatchTimeInterval.microseconds(200)
    DispatchQueue.main.asyncAfter(deadline: time) {
      textView.isScrollEnabled = textView.intrinsicContentSize.height > textView.frame.height
    }
  }
}
