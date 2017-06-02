//
//  SearchFilterTableViewSectionHeaderView.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol SearchFilterTableViewSectionHeaderViewDelegate: class {
  func sectionHeader(view: SearchFilterTableViewSectionHeaderView, request mode: SearchFilterTableViewSectionHeaderView.Mode)
}

class SearchFilterTableViewSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "SearchFilterTableViewSectionHeaderViewReuseIdentifier"
  static let nib: UINib = UINib(nibName: "SearchFilterTableViewSectionHeaderView", bundle: nil)

  enum Mode {
    case collapsed
    case expanded

    mutating func toggle() {
      switch self {
      case .collapsed:
        self = .expanded
      case .expanded:
        self = .collapsed
      }
    }
  }

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var separatorView: UIView!
  @IBOutlet var subTitleHeightLayoutConstraint: NSLayoutConstraint!

  private let subTitleHeightLayoutConstraintDefaultValue: CGFloat = 21.0

  var delegate: SearchFilterTableViewSectionHeaderViewDelegate?
  var section: Int?

  var mode: Mode = .collapsed {
    didSet {
      applyMode()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    imageView.image = #imageLiteral(resourceName: "downArrow")

    let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandle(_:)))
    self.addGestureRecognizer(recognizer)

    subTitleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: NSKeyValueObservingOptions.new, context: nil)
  }

  deinit {
    subTitleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text))
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let keyPath = keyPath, keyPath == "text" {
      guard let change = change else {
        return
      }

      let val = change[NSKeyValueChangeKey.newKey] as? String
      subTitleHeightLayoutConstraint.constant = val.isEmptyOrNil() ? 0.0 : subTitleHeightLayoutConstraintDefaultValue
    }
  }

  fileprivate func applyMode() {
    let transform: CGAffineTransform
    switch mode {
    case .collapsed:
      transform = CGAffineTransform.identity
    case .expanded:
      transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
    }

    UIView.animate(withDuration: 0.4, animations: {
      self.imageView.transform = transform
    })
  }

  @objc
  private func tapGestureHandle(_ sender: UITapGestureRecognizer) {
    self.mode.toggle()
    delegate?.sectionHeader(view: self, request: self.mode)
  }
}

extension SearchFilterTableViewSectionHeaderView: Themeable {
  func applyTheme() {
    contentView.backgroundColor = UIColor.white
    titleLabel.font = FontDynamicType.footnote.font
    titleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    subTitleLabel.font = FontDynamicType.caption2.font
    subTitleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

    imageView.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
  }
}
