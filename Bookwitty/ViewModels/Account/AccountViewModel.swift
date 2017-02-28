//
//  AccountViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class AccountViewModel {
  let viewControllerTitle: String = Strings.account()
  let myOrdersText: String = Strings.my_orders()
  let addressBookText: String = Strings.address_book()
  let paymentMethodsText: String = Strings.payment_methods()
  let settingsText: String = Strings.settings()
  let penNamesText: String = Strings.pen_names()
  let draftsText: String = Strings.drafts()
  let interestsText: String = Strings.interests()
  let readingListsText: String = Strings.reading_lists()
  let createNewPenNameText: String = Strings.create_new_pen_names()
  let customerServiceText: String = Strings.customer_service()
  let helpText: String = Strings.help()
  let contactUsText: String = Strings.contact_us()

  enum Sections: Int {
    case UserInformation
    case PenNames
    case CustomerService
    case CreatePenNames
  }

  private let sectionTitles: [String]

  init () {
    sectionTitles = ["", penNamesText, customerServiceText]
  }

  private let user: User = UserManager.shared.signedInUser

  func headerInformation() -> (name: String, image: UIImage?) {
    let nameFormatter = PersonNameComponentsFormatter()
    nameFormatter.style = .long
    var nameComponents = PersonNameComponents()
    nameComponents.givenName = user.firstName
    nameComponents.familyName = user.lastName
    return (nameFormatter.string(from: nameComponents), nil)
  }

  //User Information
  private func valuesForUserInformation(atRow row: Int) -> String {
    switch row {
    case 0:
//      return myOrdersText
//    case 1:
//      return addressBookText
//    case 2:
//      return paymentMethodsText
//    case 3:
      return settingsText
    default:
      return ""
    }
  }

  //Pen Names
  private func valuesForPenName(atRow row: Int, iteration: Int) -> (title: String, value: String) {
    switch row {
    case 0:
      return (penName(atRow: iteration), "")
    case 1:
      return (interestsText, "")
    case 2:
      return (readingListsText, "")
    default:
      return ("", "")
    }
  }

  private func penName(atRow row: Int) -> String {
    guard let penNames = user.penNames else {
      return ""
    }

    guard row >= 0 && row < penNames.count else {
      return ""
    }

    return penNames[row].name ?? ""
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
      //For now showing only settings
      numberOfRows = 1
    case Sections.PenNames.rawValue:
      //user.penNames.count * 3 (3 rows for each pen name)
      numberOfRows = (user.penNames?.count ?? 0) * 3
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
      let penNameIndex: Int = indexPath.row / 3
      let penNameSubRow = indexPath.row % 3 //(will result in 0 ... 2)
      let values = valuesForPenName(atRow: penNameSubRow, iteration: penNameIndex)
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
