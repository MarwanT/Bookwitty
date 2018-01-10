//
//  SelectPenNameViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/05.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class SelectPenNameViewModel {
  fileprivate let penNames: [PenName] = UserManager.shared.signedInUser.penNames ?? []

  fileprivate func penName(at row: Int) -> PenName? {
    guard row >= 0 && row < penNames.count else {
      return nil
    }

    return penNames[row]
  }
}

//MARK: - table view helpers
extension SelectPenNameViewModel {
  func numberOfRows() -> Int {
    return penNames.count
  }

  func values(for row: Int) -> (title: String?, value: String?, imageUrl: String?) {
    let penName = self.penName(at: row)
    return (penName?.name, "", penName?.avatarUrl)
  }
}
