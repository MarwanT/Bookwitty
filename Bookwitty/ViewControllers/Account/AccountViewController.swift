//
//  AccountViewController.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  fileprivate let viewModel = AccountViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.title = self.viewModel.viewControllerTitle
    initializeComponents()
    applyTheme()
  }

  private func initializeComponents() {
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)
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
    if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section, 0 == indexPath.row {
      return 60.0
    }

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

      currentCell.label.attributedText = NSAttributedString(string: values.title)
      currentCell.profileImageView.image = values.image

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
    default:
      return 45.0
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
