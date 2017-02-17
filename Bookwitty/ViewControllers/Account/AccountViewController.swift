//
//  AccountViewController.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class AccountViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  @IBOutlet private weak var headerView: UIView!
  @IBOutlet private weak var profileImageView: UIImageView!
  @IBOutlet private weak var displayNameLabel: TTTAttributedLabel!

  fileprivate let viewModel = AccountViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.title = self.viewModel.viewControllerTitle
    initializeComponents()
    applyTheme()
    fillUserInformation()
  }

  private func initializeComponents() {
    self.profileImageView.layer.masksToBounds = true
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2.0

    self.headerView.layoutMargins.left = ThemeManager.shared.currentTheme.generalExternalMargin()
    self.headerView.layoutMargins.right = ThemeManager.shared.currentTheme.generalExternalMargin()
    self.displayNameLabel.font = FontDynamicType.subheadline.font

    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  private func fillUserInformation() {
    self.displayNameLabel.text = "Joe Satriani"//Todo: grab the values from the vm when available
    self.profileImageView.image = nil//Todo: grab the values from the vm when available
    self.profileImageView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    self.profileImageView.tintColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }

  fileprivate func dispatchSelectionAt(_ indexPath: IndexPath) {
    switch indexPath.section {
    case AccountViewModel.Sections.UserInformation.rawValue:
      break
    case AccountViewModel.Sections.PenNames.rawValue:
      break
    case AccountViewModel.Sections.CreatePenNames.rawValue:
      break
    case AccountViewModel.Sections.CustomerService.rawValue:
      break
    default:
      break
    }
  }
}

extension AccountViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRowsIn(section: section)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45.0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var reuseIdentifier: String

    if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section, 0 == indexPath.row {
      reuseIdentifier = AccountPenNameTableViewCell.reuseIdentifier
    } else {
      reuseIdentifier = DisclosureTableViewCell.identifier
    }

    return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = viewModel.values(forRowAt: indexPath)

    if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section, 0 == indexPath.row {
      guard let currentCell = cell as? AccountPenNameTableViewCell else {
        return
      }

      currentCell.label.text = values.title
      currentCell.profileImageView.image = values.image
      currentCell.profileImageView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    } else {
      guard let currentCell = cell as? DisclosureTableViewCell else {
        return
      }

      //Indentation doesn't work with `DisclosureTableViewCell`
      //Fix the contentView margins to mimic the indentation
      let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
      if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section {
        currentCell.contentView.layoutMargins.left = leftMargin + 45.0
      } else {
        currentCell.contentView.layoutMargins.left = leftMargin
      }

      currentCell.label.font = FontDynamicType.caption1.font
      currentCell.label.text = values.title
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSectionHeaderView.reuseIdentifier) as? TableViewSectionHeaderView
    sectionView?.label.text = viewModel.titleFor(section: section)
    sectionView?.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    return sectionView
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case AccountViewModel.Sections.UserInformation.rawValue:
      return 0
    case AccountViewModel.Sections.CreatePenNames.rawValue:
      return 15.0
    default:
      return 45.0
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    dispatchSelectionAt(indexPath)
  }
}
