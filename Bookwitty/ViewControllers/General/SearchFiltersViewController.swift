//
//  SearchFiltersViewController.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SearchFiltersViewController: UIViewController {

  let viewModel: SearchFiltersViewModel = SearchFiltersViewModel()

  @IBOutlet var tableView: UITableView!

  @IBOutlet var tableViewHeader: UIView!
  @IBOutlet var tableViewHeaderButton: UIButton!
  @IBOutlet var separators: [UIView]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    addObservers()
  }

  fileprivate func initializeComponents() {
    applyLocalization()

    tableView.register(SearchFilterTableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: SearchFilterTableViewSectionHeaderView.reuseIdentifier)
  }

  fileprivate func addObservers() {
    observeLanguageChanges()
  }
}

extension SearchFiltersViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 0 //TODO: get the value from the view model
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0 //TODO: get the value from the view model
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let currentCell = cell as? CheckmarkTableViewCell else {
      return
    }

    currentCell.titleLabel.text = nil //TODO: get the value from the view model
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50.0
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchFilterTableViewSectionHeaderView.reuseIdentifier) as? SearchFilterTableViewSectionHeaderView
    sectionHeader?.titleLabel.text = nil //TODO: get the value from the view model
    sectionHeader?.subTitleLabel.text = nil //TODO: get the value from the view model
    return sectionHeader
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
}

//MARK: - Themeable implementation
extension SearchFiltersViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    tableViewHeader.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    tableViewHeaderButton.setTitleColor(ThemeManager.shared.currentTheme.defaultButtonColor(), for: .normal)
    tableView.backgroundColor = UIColor.clear

    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    tableViewHeader.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }
  }
}

//MARK: - Localizable implementation
extension SearchFiltersViewController: Localizable {
  func applyLocalization() {
    //TODO: Localize
    title = "Filters"
    tableViewHeaderButton.setTitle("Clear all", for: .normal)
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
