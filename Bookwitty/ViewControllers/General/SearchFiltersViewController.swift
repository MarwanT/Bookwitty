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
  }

  fileprivate func initializeComponents() {
    applyLocalization()
  }

  fileprivate func addObservers() {
    observeLanguageChanges()
  }
}

//MARK: - Themeable implementation
extension SearchFiltersViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()
    tableViewHeader.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    tableViewHeaderButton.setTitleColor(ThemeManager.shared.currentTheme.defaultButtonColor(), for: .normal)

    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }
  }
}

//MARK: - Localizable implementation
extension SearchFiltersViewController: Localizable {
  func applyLocalization() {
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
