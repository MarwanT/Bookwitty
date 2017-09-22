//
//  RichEditorOption.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import RichEditorView
import UIKit

enum ContentEditorOption : RichEditorOption {

  case bold
  case italic
  case header
  case unorderedList
  case link
  case undo
  case redo
  
  public static let toolbarOptions: [ContentEditorOption] = [
    .header,
    .bold,
    .italic,
    .unorderedList,
    .link,
  ]
  
  // MARK: RichEditorOption
  
  public var image: UIImage? {
    var name = ""
    switch self {
    case .bold: name = "bold"
    case .italic: name = "italic"
    case .header: name = "textSize"
    case .unorderedList: name = "bullets"
    case .link: name = "hyperlinkSmall"
    case .undo: name = "undo"
    case .redo: name = "redo"
    }
    
    let bundle = Bundle.main
    return UIImage(named: name, in: bundle, compatibleWith: nil)?.imageWithSize(size: CGSize(width: CGFloat(Int.max), height: 44))
  }
  
  public var title: String {
    return ""
  }
  
  public func action(_ toolbar: RichEditorToolbar) {
    switch self {
    case .bold: toolbar.editor?.bold()
    case .italic: toolbar.editor?.italic()
    case .header: toolbar.editor?.header(2)
    case .unorderedList: toolbar.editor?.unorderedList()
    case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
    case .undo : toolbar.editor?.undo()
    case .redo : toolbar.editor?.redo()
    }
  }
}
