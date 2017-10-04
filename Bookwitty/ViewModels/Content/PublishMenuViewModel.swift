//
//  PublishMenuViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PublishMenuViewModel {
  let items: [PublishMenuViewController.Item] = [.penName, .linkTopics, .addTags, .postPreview, .publishYourPost, .saveAsDraft, .goBack]

  //MARK: - TableView functions
  func numberOfRows() -> Int {
    return items.count
  }
  
  func values(forRowAt indexPath: IndexPath) -> (label: String?, image: UIImage?) {
    guard let item = PublishMenuViewController.Item(rawValue:indexPath.row) else {
      return (nil, nil)
    }
    return (item.localizedString, item.image)
  }
}
