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

  var delegate: SearchFilterTableViewSectionHeaderViewDelegate?
  var section: Int?

  fileprivate var mode: Mode = .collapsed {
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
