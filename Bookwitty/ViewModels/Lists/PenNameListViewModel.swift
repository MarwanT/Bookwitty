//
//  PenNameListViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class PenNameListViewModel {
  private(set) var penNames: [PenName] = []

  func initialize(with penNames: [PenName]) {
    self.penNames = penNames
  }

  func penName(at item: Int) -> PenName? {
    guard item >= 0 && item < penNames.count else {
      return nil
    }

    return penNames[item]
  }
}

//MARK: - ASCollectionDataSource helpers
extension PenNameListViewModel {
  func numberOfPenNames() -> Int {
    return penNames.count
  }

  func values(at item: Int) -> (identifier: String?, penName: String?, biography: String?, imageUrl: String?, following: Bool, isMyPenName: Bool)? {
    guard let penName = penName(at: item) else {
      return nil
    }

    let mine = UserManager.shared.isMy(penName: penName)
    return (penName.id, penName.name, penName.biography, penName.avatarUrl, penName.following, mine)
  }
}

//MARK: - Actions
extension PenNameListViewModel {

}
