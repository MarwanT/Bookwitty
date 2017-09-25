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

  fileprivate func getUrlInfo() {
    guard !textView.text.isEmpty, let url = URL(string: textView.text) else {
      return
    }

    IFramely.shared.loadResponseFor(url: url, closure: { (response: Response?) in
      defer {
        DispatchQueue.main.async {
          self.showLinkPreview()
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
    //re-initilize components
    initializeComponents()
    
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
    videoImageView.sd_setImage(with: imageUrl)

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
