//
//  AccountViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class AccountViewModel {
  enum Sections: Int {
    case UserInformation
    case PenNames
    case CreatePenNames
    case CustomerService
  }

  private var sectionTitles: [String] = []

  let numberOfRowsPerPenName: Int = 2

  init () {
    self.fillSectionTitles()
  }

  private let user: User = UserManager.shared.signedInUser

  func fillSectionTitles() {
    self.sectionTitles.removeAll()
    self.sectionTitles += ["", Strings.pen_names(), "", Strings.customer_service()]
  }

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
//      return Strings.my_orders()
//    case 1:
//      return Strings.address_book()
//    case 2:
//      return Strings.payment_methods()
//    case 3:
      return Strings.settings()
    default:
      return ""
    }
  }

  //Pen Names
  private func valuesForPenName(atRow row: Int, iteration: Int) -> (title: String, value: String, image: String?) {
    switch row {
    case 0:
      let pen: PenName? = penName(atRow: iteration)
      return (pen?.name ?? "", "", pen?.avatarUrl)
    case 1:
      return (Strings.edit_pen_name(), "", nil)
    //WAS: return (Strings.interests(), "")
    case 2:
      return (Strings.reading_lists(), "", nil)
    default:
      return ("", "", nil)
    }
  }

  private func penName(atRow row: Int) -> PenName? {
    guard let penNames = user.penNames else {
      return nil
    }

    guard row >= 0 && row < penNames.count else {
      return nil
    }

    return penNames[row]
  }

  func selectedPenName(atRow row: Int) -> PenName? {
    return penName(atRow: row / numberOfRowsPerPenName)
  }

  //Create Pen Names
  private func valuesForCreatePenName(atRow row: Int) -> String {
    switch row {
    case 0:
      return Strings.create_new_pen_name()
    default:
      return ""
    }
  }

  //Customer Service
  private func valuesForCustomerService(atRow row: Int) -> String {
    switch row {
    case 0:
      return Strings.help()
    case 1:
      return Strings.contact_us()
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
      //WAS: (user.penNames?.count ?? 0) * 3
      numberOfRows = (user.penNames?.count ?? 0) * numberOfRowsPerPenName
    case Sections.CreatePenNames.rawValue:
      numberOfRows = 1
    case Sections.CustomerService.rawValue:
      //WAS 2
      numberOfRows = 1
    default:
      break
    }
    return numberOfRows
  }

  func values(forRowAt indexPath: IndexPath) -> (title: String, value: String, imageUrl: String?) {
    var title: String = ""
    var value: String = ""
    var image: String? = nil
    switch indexPath.section {
    case Sections.UserInformation.rawValue:
      title = valuesForUserInformation(atRow: indexPath.row)
      value = ""
    case Sections.PenNames.rawValue:
      let penNameIndex: Int = indexPath.row / numberOfRowsPerPenName
      let penNameSubRow = indexPath.row % numberOfRowsPerPenName //(will result in 0 ... numberOfRowsPerPenName)
      let values = valuesForPenName(atRow: penNameSubRow, iteration: penNameIndex)
      title = values.title
      value = values.value
      if penNameSubRow == 0 {
        image = values.image
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
