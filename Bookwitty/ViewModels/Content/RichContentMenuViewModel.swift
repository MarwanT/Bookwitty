//
//  RichContentMenuViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class RichContentMenuViewModel {
 
  let items: [RichContentMenuViewController.Item] = [.imageCamera, .imageLibrary, .link, .book, .video, .audio, .quote]
  
  //MARK: - TableView functions
  func numberOfRows() -> Int {
    return items.count
  }
}
