//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PenNameViewModel {
  let viewControllerTitle: String = localizedString(key: "choose_pen_name", defaultValue: "Choose a Pen Name")

  let continueButtonTitle: String = localizedString(key: "continue", defaultValue: "Continue")

  let penNameTextFieldPlaceholderText: String = localizedString(key: "enter_your_pen_name", defaultValue: "Enter your pen name")
  let penNameInvalidationErrorMessage: String = localizedString(key: "pen_name_cant_be_empty", defaultValue: "Oooops pen name can not be empty")

  let penNameTitleText: String = localizedString(key: "pen_name", defaultValue: "Pen Name")
  let penNameNoteText: String = localizedString(key: "dont_worry_you_can_always_change_it_later", defaultValue: "Don't worry, you can always change it later")

  let imagePickerTitle: String = localizedString(key: "profile_picture", defaultValue: "Profile Picture")
  let takeProfilePhotoText: String = localizedString(key: "take_Profile_photo", defaultValue: "Take profile photo")
  let chooseFromLibraryText: String = localizedString(key: "choose_from_library", defaultValue: "Choose photo from library")
  let removeProfilePhotoText: String = localizedString(key: "clear_profile_photo", defaultValue: "Clear profile photo")
  let cancelText: String = localizedString(key: "cancel", defaultValue: "Cancel")
  let doneText: String = localizedString(key: "done", defaultValue: "Done")

  private(set) var user: User!

  func penDisplayName() -> String {
    let firstName = user.firstName ?? ""
    let lastName = user.lastName ?? ""
    return firstName + " " + lastName
  }

  func initializeWith(user: User) {
    self.user = user
  }
}
