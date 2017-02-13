//
//  AccountViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class AccountViewModel {
  let viewControllerTitle: String = localizedString(key: "account", defaultValue: "Account")
  let myOrdersText: String = localizedString(key: "my_orders", defaultValue: "My Orders")
  let addressBookText: String = localizedString(key: "address_book", defaultValue: "Address Book")
  let paymentMethodsText: String = localizedString(key: "payment_methods", defaultValue: "Payment Methods")
  let settingsText: String = localizedString(key: "settings", defaultValue: "Settings")
  let penNamesText: String = localizedString(key: "pen_names", defaultValue: "Pen Names")
  let draftsText: String = localizedString(key: "drafts", defaultValue: "Drafts")
  let interestsText: String = localizedString(key: "interests", defaultValue: "Interests")
  let readingListsText: String = localizedString(key: "reading_lists", defaultValue: "Reading Lists")
  let createNewPenNameText: String = localizedString(key: "create_new_pen_names", defaultValue: "Create New Pen Name")
  let customerServiceText: String = localizedString(key: "customer_service", defaultValue: "Customer Service")
  let helpText: String = localizedString(key: "help", defaultValue: "Help")
  let contactUsText: String = localizedString(key: "contact_us", defaultValue: "Contact Us")

  private enum Sections: Int {
    case UserInformation = 0
    case PenNames = 1
    case CreatePenNames = 2
    case CustomerService = 3
  }

  private let sectionTitles: [String]

  init () {
    sectionTitles = ["", penNamesText, "", customerServiceText]
  }

  //User Information
  private func valuesForUserInformation(atRow row: Int) -> String {
    switch row {
    case 0:
      return myOrdersText
    case 1:
      return addressBookText
    case 2:
      return paymentMethodsText
    case 3:
      return settingsText
    default:
      return ""
    }
  }

  //Pen Names
  private func valuesForPenName(atRow row: Int) -> (title: String, value: String) {
    switch row {
    case 0:
      return ("", "")
    case 1:
      return (interestsText, "")
    case 2:
      return (readingListsText, "")
    default:
      return ("", "")
    }
  }

  //Create Pen Names
  private func valuesForCreatePenName(atRow row: Int) -> String {
    switch row {
    case 0:
      return createNewPenNameText
    default:
      return ""
    }
  }

}
