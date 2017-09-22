//
//  RichLinkPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RichLinkPreviewViewController: UIViewController {

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

  fileprivate let viewModel = RichLinkPreviewViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    applyTheme()
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
  }
}

extension RichLinkPreviewViewController: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    textView.isScrollEnabled = false
    return true
  }

  public func textViewDidChange(_ textView: UITextView) {
    let time: DispatchTime = DispatchTime.now() + DispatchTimeInterval.microseconds(200)
    DispatchQueue.main.asyncAfter(deadline: time) {
      textView.isScrollEnabled = textView.intrinsicContentSize.height > textView.frame.height
    }
  }
}
