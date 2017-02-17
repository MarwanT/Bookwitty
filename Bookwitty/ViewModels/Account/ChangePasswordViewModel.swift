//
//  ChangePasswordViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class ChangePasswordViewModel {
  let currentPasswordText: String = localizedString(key: "current_password", defaultValue: "Current Password")
  let newPasswordText: String = localizedString(key: "new_password", defaultValue: "New Password")
  let changePasswordText: String = localizedString(key: "change_password", defaultValue: "Change Password")
  let changePasswordSuccessNotification: String = localizedString(key: "change_password_success", defaultValue: "Password changed successfully")
  let changePasswordErrorNotification: String = localizedString(key: "change_password_error", defaultValue: "Could not change password")
}
