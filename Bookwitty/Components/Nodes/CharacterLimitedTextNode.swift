//
//  CharacterLimitedTextNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/23/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText
import Foundation

protocol CharacterLimitedTextNodeDelegate: class {
  func characterLimitedTextNodeDidTap(_ node: CharacterLimitedTextNode)
}

class CharacterLimitedTextNode: ASTextNode {
  enum Mode {
    case collapsed
    case expanded
  }

  var maxCharacter: Int = 140 {
    didSet{
      setNeedsLayout()
    }
  }
  var autoChange: Bool = true
  var nodeDelegate: CharacterLimitedTextNodeDelegate?

  private var originalText: String?
  private var fontDynamicType: FontDynamicType? = nil
  private var color: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
  private var htmlImageWidth: CGFloat = UIScreen.main.bounds.width

  var mode: Mode = .collapsed {
    didSet {
      self.setString(text: originalText, fontDynamicType: fontDynamicType, color: color)
    }
  }

  override func didLoad() {
    super.didLoad()
    self.addTarget(self, action: #selector(didTapNode(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  func setString(text: String?, fontDynamicType: FontDynamicType?, color: UIColor) {
    self.originalText = text
    self.fontDynamicType = fontDynamicType
    self.color = color
    let processedText = (mode == .collapsed || autoChange) ? getProcessedText(for: text) : text

    let finalStr = attributedString(text: processedText ?? "", fontDynamicType: self.fontDynamicType,
                                    color: self.color)
    self.attributedText = finalStr
  }

  private func attributedString(text: String, fontDynamicType: FontDynamicType? = nil,
                                color: UIColor =  ThemeManager.shared.currentTheme.defaultTextColor()) -> NSAttributedString? {
    let addMore = (mode == .collapsed) && shouldTruncate(text: self.originalText ?? "", maxCharacter: maxCharacter)
    let attributedString = AttributedStringBuilder(fontDynamicType: fontDynamicType ?? FontDynamicType.caption1)
      .append(text: text, color: color)
      .append(text: addMore ?  "..." : "")
      .append(text: addMore ? Strings.more() : "", color: ThemeManager.shared.currentTheme.colorNumber19())
      .attributedString
    return attributedString
  }

  // MARK: Actions
  //==============
  func didTapNode(_ sender: ASTextNode) {
    if autoChange && shouldTruncate(text: originalText ?? "", maxCharacter: maxCharacter) {
      toggle()
    }
    nodeDelegate?.characterLimitedTextNodeDidTap(self)
  }

  // MARK: Helpers
  //==============
  func toggle() {
    switch mode {
    case .collapsed:
      mode = .expanded
    case .expanded:
      mode = .collapsed
    }
  }

  private func getProcessedText(for text: String?) -> String {
    guard let text = text, text.count > 0 else {
      return ""
    }
    guard shouldTruncate(text: text, maxCharacter: maxCharacter) else {
      return text
    }

    return createCharacterLimited(text: text, maxCharacter: maxCharacter)
  }

  private func shouldTruncate(text: String, maxCharacter: Int) -> Bool {
    return text.count > maxCharacter
  }

  private func createCharacterLimited(text: String, maxCharacter: Int) -> String {
    let index: String.Index = text.index(text.startIndex, offsetBy: (text.count > maxCharacter) ? maxCharacter : text.count)
    let characterLimitedText = text.substring(to: index)
    return characterLimitedText
  }
}
