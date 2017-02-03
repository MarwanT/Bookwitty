//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PenNameViewModel {
  let viewControllerTitle: String = localizedString(key: "pen_name", defaultValue: "Choose a Pen Name")

  let continueButtonTitle: String = localizedString(key: "continue", defaultValue: "Continue")

  let penNameTextFieldPlaceholderText: String = localizedString(key: "email_text_field_pen_name", defaultValue: "Enter your pen name")
  let penNameInvalidationErrorMessage: String = localizedString(key: "pen_name_invalidation_error_message", defaultValue: "Oooops pen name can not be empty")

  let penNameTitleText: String = localizedString(key: "pen_name_title", defaultValue: "Pen Name")
  let penNameNoteText: String = localizedString(key: "pen_name_note", defaultValue: "Don't worry, you can always change it later")

  let imagePickerTitle: String = localizedString(key: "image_picker_title", defaultValue: "Profile Picture")
  let takeProfilePhotoText: String = localizedString(key: "take_Profile_photo", defaultValue: "Take profile photo")
  let chooseFromLibraryText: String = localizedString(key: "choose_from_library", defaultValue: "Choose photo from library")
  let removeProfilePhotoText: String = localizedString(key: "remove_profile_photo", defaultValue: "Clear profile photo")
  let cancelText: String = localizedString(key: "cancel", defaultValue: "Cancel")

}
