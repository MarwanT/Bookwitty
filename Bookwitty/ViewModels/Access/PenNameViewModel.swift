//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PenNameViewModel {
  let viewControllerTitle: String = Strings.choose_pen_name()

  let continueButtonTitle: String = Strings.continue()

  let penNameTextFieldPlaceholderText: String = Strings.enter_your_pen_name()
  let penNameInvalidationErrorMessage: String = Strings.pen_name_cant_be_empty()

  let penNameTitleText: String = Strings.pen_name()
  let penNameNoteText: String = Strings.dont_worry_you_can_change_it_later()

  let imagePickerTitle: String = Strings.profile_picture()
  let takeProfilePhotoText: String = Strings.take_Profile_photo()
  let chooseFromLibraryText: String = Strings.choose_from_library()
  let removeProfilePhotoText: String = Strings.clear_profile_photo()
  let cancelText: String = Strings.cancel()
  let doneText: String = Strings.done()

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
