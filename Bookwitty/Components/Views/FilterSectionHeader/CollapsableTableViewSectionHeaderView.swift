//
//  CollapsableTableViewSectionHeaderView.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol CollapsableTableViewSectionHeaderViewDelegate: class {
  func sectionHeader(view: CollapsableTableViewSectionHeaderView, request mode: CollapsableTableViewSectionHeaderView.Mode)
}

class CollapsableTableViewSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "CollapsableTableViewSectionHeaderViewReuseIdentifier"
  static let nib: UINib = UINib(nibName: "CollapsableTableViewSectionHeaderView", bundle: nil)

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
  
  var configuration = Configuration() {
    didSet {
      applyTheme()
      layoutIfNeeded()
    }
  }

  var delegate: CollapsableTableViewSectionHeaderViewDelegate?
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

extension CollapsableTableViewSectionHeaderView: Themeable {
  func applyTheme() {

    /** Discussion
     * Setting the background color on UITableViewHeaderFooterView has been deprecated, BUT contentView.backgroundColor was not working on the IPOD or IPHONE-5/s
     * so we kept both until 'contentView.backgroundColor' work 100% on all supported devices
     */
    contentView.backgroundColor = configuration.backgroundColor
    backgroundColor = configuration.backgroundColor
    if let imagebg = configuration.backgroundColor.image(size: self.frame.size) {
      self.backgroundView = UIImageView(image: imagebg)
    }

    titleLabel.font = configuration.titleLabelFont
    titleLabel.textColor = configuration.titleLabelTextColor
    titleLabel.backgroundColor = UIColor.clear
    
    subTitleLabel.font = configuration.subTitleLabelFont
    subTitleLabel.textColor = configuration.subTitleLabelTextColor
    subTitleLabel.backgroundColor = UIColor.clear
    
    separatorView.backgroundColor = configuration.separatorColor
    layoutMargins = configuration.contentLayoutMargin
    
    imageView.tintColor = configuration.imageTintColor
  }
}

extension CollapsableTableViewSectionHeaderView {
  struct Configuration {
    var titleLabelFont = FontDynamicType.footnote.font
    var titleLabelTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var subTitleLabelFont = FontDynamicType.caption2.font
    var subTitleLabelTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    var separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    var contentLayoutMargin = UIEdgeInsets(
      top: 0.0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0.0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var imageTintColor = ThemeManager.shared.currentTheme.colorNumber20()
  }
}
