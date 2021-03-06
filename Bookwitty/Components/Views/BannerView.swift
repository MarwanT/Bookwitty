//
//  BannerView.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout
import SDWebImage

class BannerView: UIView, Themeable {
  let imageView = UIImageView(frame: CGRect.zero)
  let labelsContainerView = UIView(frame: CGRect.zero)
  let titleLabel = UILabel(frame: CGRect.zero)
  let descriptionLabel = UILabel(frame: CGRect.zero)
  let dimView: UIView = UIView(frame: CGRect.zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    initializeViews()
    addSubviews()
    setConstraints()
    applyTheme()
  }
  
  func initializeViews() {
    clipsToBounds = true
    titleLabel.numberOfLines = 0
    descriptionLabel.numberOfLines = 0
    imageView.contentMode = UIViewContentMode.scaleAspectFill
    titleLabel.textAlignment = NSTextAlignment.center
    descriptionLabel.textAlignment = NSTextAlignment.center
    dimView.backgroundColor = UIColor.bwNero.withAlphaComponent(0.5)
  }
  
  private func addSubviews() {
    labelsContainerView.addSubview(titleLabel)
    labelsContainerView.addSubview(descriptionLabel)
    self.addSubview(imageView)
    self.addSubview(labelsContainerView)
    
    self.insertSubview(dimView, aboveSubview: imageView)
  }
  
  func setConstraints() {
    let descriptionTopSpace: CGFloat = ThemeManager.shared.currentTheme.titleMargin()
    let minimumHeight: CGFloat = 150
    
    imageView.alignTop("0@500", leading: "0", bottom: "0@500", trailing: "0", toView: self)
    self.constrainHeight("\(minimumHeight)@750")
    
    titleLabel.alignLeading("0", trailing: "0", toView: labelsContainerView)
    descriptionLabel.alignLeading("0", trailing: "0", toView: labelsContainerView)
    titleLabel.alignTopEdge(withView: labelsContainerView, predicate: "0")
    descriptionLabel.constrainTopSpace(toView: titleLabel, predicate: "\(descriptionTopSpace)")
    labelsContainerView.alignBottomEdge(withView: descriptionLabel, predicate: "0")
    
    labelsContainerView.alignLeading("0", trailing: "0", toView: self)
    labelsContainerView.alignCenterY(withView: self, predicate: "0")
    labelsContainerView.alignTopEdge(withView: self, predicate: ">=10")
    
    dimView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: imageView)
  }
  
  func applyTheme() {
    titleLabel.textColor = ThemeManager.shared.currentTheme.colorNumber23()
    descriptionLabel.textColor = ThemeManager.shared.currentTheme.colorNumber23()
    titleLabel.font = FontDynamicType.title2.font
    descriptionLabel.font = FontDynamicType.footnote.font
  }
  
  
  // MARK: - APIs
  
  var imageURL: URL? {
    get {
      return imageView.sd_imageURL()
    }
    set (imageURL) {
      imageView.sd_setImage(with: imageURL)
    }
  }
  
  var title: String? {
    get {
      return titleLabel.text
    }
    set (title) {
      titleLabel.text = title
    }
  }
  
  var subtitle: String? {
    get {
      return descriptionLabel.text
    }
    set (subtitle) {
      descriptionLabel.text = subtitle
    }
  }
}
