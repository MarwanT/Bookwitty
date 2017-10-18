//
//  ChipsTableViewCell.swift
//  Bookwitty
//
//  Created by ibrahim on 10/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField
class ChipsTableViewCell: UITableViewCell {
  @IBOutlet weak var cellImageView: UIImageView!
  @IBOutlet weak var tagsView: WSTagsField!
  var height: CGFloat = 44.0
  static let identifier = "ChipsTableViewCellReuseableIdentifier"
  override func awakeFromNib() {
    super.awakeFromNib()
    tagsView.readOnly = true
    tagsView.onDidChangeHeightTo = { _, height in
      self.height = height
    }
  }
  
  func setTags(_ tags:[String])  {
    tags.forEach { tagsView.addTag($0) }
  }
}
