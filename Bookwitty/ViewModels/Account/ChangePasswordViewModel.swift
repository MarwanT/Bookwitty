//
//  ChangePasswordViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class ChangePasswordViewModel {
  func updatePassword(identifier: String, current: String, new: String, closure: ((Bool, Error?) -> Void)?) {
    let _ = UserAPI.updateUser(identifier: identifier, currentPassword: current, password: new) {
      (success: Bool, user: User?, error: BookwittyAPIError?) in
      closure?(success, error)
    }
  }
}
