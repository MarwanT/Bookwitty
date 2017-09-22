//
//  RichEditorOption.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import RichEditorView
import UIKit

enum RichEditorBookwittyOption : RichEditorOption {
  
//  case clear
//  case undo
//  case redo
  case bold
  case italic
  case header(Int)
  case unorderedList
  case link
  
  public static let all: [RichEditorBookwittyOption] = [
    .header(2),
    .bold,
    .italic,
    .unorderedList,
    .link
  ]
  
  // MARK: RichEditorOption
  
  public var image: UIImage? {
    var name = ""
    switch self {
    case .bold: name = "bold"
    case .italic: name = "italic"
    case .header( _): name = "textSize"
    case .unorderedList: name = "bullets"
    case .link: name = "hyperlinkSmall"
    }
    
    let bundle = Bundle.main
    return UIImage(named: name, in: bundle, compatibleWith: nil)?.imageWithSize(size: CGSize(width: CGFloat(Int.max), height: 44))
  }
  
  public var title: String {
    switch self {
    case .bold: return NSLocalizedString("Bold", comment: "")
    case .italic: return NSLocalizedString("Italic", comment: "")
    case .header(let h): return NSLocalizedString("H\(h)", comment: "")
    case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
    case .link: return NSLocalizedString("Link", comment: "")
    }
  }
  
  public func action(_ toolbar: RichEditorToolbar) {
    switch self {
    case .bold: toolbar.editor?.bold()
    case .italic: toolbar.editor?.italic()
    case .header(let h): toolbar.editor?.header(h)
    case .unorderedList: toolbar.editor?.unorderedList()
    case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
    }
  }
}
