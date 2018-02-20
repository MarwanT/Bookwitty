//
//  UISearchBar+Utils.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension UISearchBar {

  private func getViewElement<T>(type: T.Type) -> T? {

    let svs = subviews.flatMap { $0.subviews }
    guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
    return element
  }

  func getSearchBarTextField() -> UITextField? {

    return getViewElement(type: UITextField.self)
  }

  func setTextColor(color: UIColor) {

    if let textField = getSearchBarTextField() {
      textField.textColor = color
    }
  }

  func setTextFieldColor(color: UIColor) {
    var searchFieldImage: UIImage? = color.image(size: CGSize(width: 28.0, height: 12.0))
    if searchFieldImage != nil {
      searchFieldImage = UIImage.roundedImage(image: searchFieldImage!, cornerRadius: 4)
    }
    
    setSearchFieldBackgroundImage(searchFieldImage, for: UIControlState.normal)
    searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0)
  }

  func setPlaceholderTextColor(color: UIColor) {

    if let textField = getSearchBarTextField() {
      textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSForegroundColorAttributeName: color])
    }
  }

  func setTextFieldClearButtonColor(color: UIColor) {

    if let textField = getSearchBarTextField() {

      let button = textField.value(forKey: "clearButton") as! UIButton
      if let image = button.imageView?.image {
        button.setImage(image.transform(withNewColor: color), for: .normal)
      }
    }
  }

  func setSearchImageColor(color: UIColor) {

    if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
      imageView.image = imageView.image?.transform(withNewColor: color)
    }
  }
}
