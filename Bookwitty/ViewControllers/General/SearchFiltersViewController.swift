//
//  SearchFiltersViewController.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol SearchFiltersViewControllerDelegate: class {
  func searchFilter(viewController: SearchFiltersViewController, didSelect filter: Filter)
}

class SearchFiltersViewController: UIViewController {

  let viewModel: SearchFiltersViewModel = SearchFiltersViewModel()

  @IBOutlet var tableView: UITableView!

  @IBOutlet var tableViewHeader: UIView!
  @IBOutlet var tableViewHeaderButton: UIButton!
  @IBOutlet var separators: [UIView]!

  var delegate: SearchFiltersViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    addObservers()
    setupNavigationbarButtons()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.SearchFilter)
  }

  fileprivate func initializeComponents() {
    applyLocalization()

    tableView.register(SearchFilterTableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: SearchFilterTableViewSectionHeaderView.reuseIdentifier)
  }

  fileprivate func addObservers() {
    observeLanguageChanges()
  }

  fileprivate func setupNavigationbarButtons() {
    let applyBarButtonItem = UIBarButtonItem(title: Strings.apply(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(applyTouchUpInside(_:)))
    navigationItem.rightBarButtonItem = applyBarButtonItem
  }

  @objc
  fileprivate func applyTouchUpInside(_ sender: UIBarButtonItem) {
    guard let filter = viewModel.candidateFilter else {
      return
    }

    delegate?.searchFilter(viewController: self, didSelect: filter)
  }

  @objc
  @IBAction fileprivate func clearAllTouchUpInside(_ sender: UIButton) {
    guard let filter = viewModel.candidateFilter else {
      return
    }

    filter.categories.removeAll()
    filter.languages.removeAll()
    filter.types.removeAll()

    delegate?.searchFilter(viewController: self, didSelect: filter)
  }
}

extension SearchFiltersViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let currentCell = cell as? CheckmarkTableViewCell else {
      return
    }

    let values = viewModel.values(forRowAt: indexPath)
    currentCell.titleLabel.text = values.title
    currentCell.isSelected = values.selected
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60.0
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchFilterTableViewSectionHeaderView.reuseIdentifier) as? SearchFilterTableViewSectionHeaderView
    let values = viewModel.values(for: section)
    sectionHeader?.mode = values.mode
    sectionHeader?.delegate = self
    return sectionHeader
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let sectionHeader = view as? SearchFilterTableViewSectionHeaderView else {
      return
    }

    let values = viewModel.values(for: section)
    sectionHeader.titleLabel.text = values.title
    sectionHeader.subTitleLabel.text = values.subtitle
    sectionHeader.section = section
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.toggleRow(at: indexPath)
    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
}

extension SearchFiltersViewController: SearchFilterTableViewSectionHeaderViewDelegate {
  func sectionHeader(view: SearchFilterTableViewSectionHeaderView, request mode: SearchFilterTableViewSectionHeaderView.Mode) {
    guard let section = view.section else {
      return
    }

    viewModel.toggleSection(section)
    tableView.reloadSections(IndexSet(integer: section), with: .none)
  }
}

//MARK: - Themeable implementation
extension SearchFiltersViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    tableViewHeader.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    tableViewHeaderButton.setTitleColor(ThemeManager.shared.currentTheme.defaultButtonColor(), for: .normal)
    tableViewHeaderButton.titleLabel?.font = FontDynamicType.footnote.font
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
    title = Strings.filters()
    tableViewHeaderButton.setTitle(Strings.clear_all(), for: .normal)
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
