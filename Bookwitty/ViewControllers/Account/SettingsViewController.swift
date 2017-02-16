//
//  SettingsViewController.swift
//  Bookwitty
//
//  Created by charles on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  fileprivate let viewModel = SettingsViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    setupNavigationBarButtons()
    applyTheme()
  }

  private func initializeComponents() {
    self.title = self.viewModel.viewControllerTitle
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  private func setupNavigationBarButtons() {
    
  }

  func switchValueChanged(_ sender: UISwitch) {
    let switchPoint = sender.convert(CGPoint.zero, to: tableView)
    guard let indexPath = tableView.indexPathForRow(at: switchPoint) else {
      return
    }

    viewModel.handleSwitchValueChanged(forRowAt: indexPath, newValue: sender.isOn)
  }
}

extension SettingsViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
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
    return tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = viewModel.values(forRowAt: indexPath)

    guard let currentCell = cell as? DisclosureTableViewCell else {
      return
    }

    currentCell.label.font = FontDynamicType.caption1.font
    currentCell.label.text = values.title

    let accessory = viewModel.accessory(forRowAt: indexPath)

    var hideDiclosure = true
    switch accessory {
    case .Disclosure:
      hideDiclosure = false
    case .Switch:
      let switchView = UISwitch()
      switchView.isOn = (values.value as? Bool ?? false)
      switchView.addTarget(self, action: #selector(self.switchValueChanged(_:)) , for: UIControlEvents.valueChanged)
      currentCell.accessoryView = switchView
    case .None:
      break
    }

    currentCell.disclosureImageView.isHidden = hideDiclosure
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSectionHeaderView.reuseIdentifier) as? TableViewSectionHeaderView
    sectionView?.label.text = viewModel.titleFor(section: section)
    sectionView?.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    sectionView?.separators?.first?.isHidden = section == 0

    return sectionView
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 15.0
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
