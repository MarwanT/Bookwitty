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

  enum Sections: Int {
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

  //Customer Service
  private func valuesForCustomerService(atRow row: Int) -> String {
    switch row {
    case 0:
      return helpText
    case 1:
      return contactUsText
    default:
      return ""
    }
  }

  /*
   * General table view functions
   */
  func numberOfSections() -> Int {
    return self.sectionTitles.count
  }

  func titleFor(section: Int) -> String {
    guard section >= 0 && section < self.sectionTitles.count else { return "" }

    return self.sectionTitles[section]
  }

  func numberOfRowsIn(section: Int) -> Int {
    guard section >= 0 && section < self.sectionTitles.count else { return 0 }
    
    var numberOfRows = 0
    switch section {
    case Sections.UserInformation.rawValue:
      //my orders, address book, payment methods, settings
      numberOfRows = 4
    case Sections.PenNames.rawValue:
      //user.penNames.count * 3 (3 rows for each pen name)
      numberOfRows = 3
    case Sections.CreatePenNames.rawValue:
      numberOfRows = 1
    case Sections.CustomerService.rawValue:
      numberOfRows = 2
    default:
      break
    }
    return numberOfRows
  }

  func values(forRowAt indexPath: IndexPath) -> (title: String, value: String, image: UIImage?) {
    var title: String = ""
    var value: String = ""
    var image: UIImage? = nil
    switch indexPath.section {
    case Sections.UserInformation.rawValue:
      title = valuesForUserInformation(atRow: indexPath.row)
      value = ""
    case Sections.PenNames.rawValue:
    //let penNameIndex: Int = indexPath.row / 4
      let penNameSubRow = indexPath.row % 4 //(will result in 0 ... 3)
      let values = valuesForPenName(atRow: penNameSubRow)
      title = values.title
      value = values.value
      if penNameSubRow == 0 {
        image = nil //TODO: set the pen name image
      }
    case Sections.CreatePenNames.rawValue:
      title = valuesForCreatePenName(atRow: indexPath.row)
    case Sections.CustomerService.rawValue:
      title = valuesForCustomerService(atRow: indexPath.row)
    default:
      break
    }

    return (title, value, image)
  }
}
