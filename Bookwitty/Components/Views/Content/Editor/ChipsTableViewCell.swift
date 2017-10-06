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
  
  static let identifier = "ChipsTableViewCellReuseableIdentifier"
  
  func detTags(_ tags:[String])  {
    tags.forEach { tagsView.addTag($0) }
  }
}
