//
//  SelectPenNameViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/05.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class SelectPenNameViewModel {
  fileprivate(set) var penNames: [PenName] = UserManager.shared.signedInUser.penNames ?? []
  fileprivate(set) var selectedPenName: PenName?

  fileprivate func penName(at row: Int) -> PenName? {
    guard row >= 0 && row < penNames.count else {
      return nil
    }

    return penNames[row]
  }

  func preselect(penName: PenName?) {
    selectedPenName = penName
  }

  func reloadData() {
    self.penNames = UserManager.shared.signedInUser.penNames ?? []
  }
}

//MARK: - table view helpers
extension SelectPenNameViewModel {
  func numberOfRows(in section: Int) -> Int {
    guard let section = SelectPenNameViewController.Sections(rawValue: section) else {
      return 0
    }

    switch section {
    case .list:
      return penNames.count
    case .new:
      return 1
    }
  }

  func values(for row: Int) -> (title: String?, value: String?, imageUrl: String?, selected: Bool) {
    let penName = self.penName(at: row)

    let selected: Bool
    if let selectedPenName = selectedPenName, let penName = penName,
      let selectedIdentifier = selectedPenName.id, let penIdentifier = penName.id {
      selected = selectedIdentifier == penIdentifier
    } else {
      selected = false
    }
    return (penName?.name, "", penName?.avatarUrl, selected)
  }

  func selectPenName(at row: Int) {
    guard let penName = self.penName(at: row) else {
      return
    }

    if selectedPenName != penName {
      selectedPenName = penName
    }
  }
}
