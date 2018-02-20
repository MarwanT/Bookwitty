//
//  EmailSettingsViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/01.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class EmailSettingsViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  fileprivate let viewModel = EmailSettingsViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
  }

  fileprivate func syncUserPreferences() {
    viewModel.syncPreferences { (success) in
      if (success) {
        self.tableView.reloadData()
      }
    }
  }

  fileprivate func initializeComponents() {
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  @objc
  fileprivate func switchValueChanged(_ sender: UISwitch) {
    let switchPoint = sender.convert(CGPoint.zero, to: tableView)
    guard let indexPath = tableView.indexPathForRow(at: switchPoint) else {
      return
    }

    //MARK: [Analytics] Event
    let label: String = sender.isOn ? "On" : "Off"

    var action = Analytics.Action.Default
    switch indexPath.row {
    case 0:
      action = Analytics.Action.SwitchCommentsEmailNotification
    case 1:
      action = Analytics.Action.SwitchFollowersEmailNotification
    case 2:
      action = Analytics.Action.SwitchNewsletterEmailNotification
    default:
      break
    }

    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: action,
                                                 name: label)
    Analytics.shared.send(event: event)

    viewModel.handleSwitchValueChanged(forRowAt: indexPath, newValue: sender.isOn) {
      (value: Bool) -> () in
      sender.isOn = value
    }
  }
}

extension EmailSettingsViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension EmailSettingsViewController: UITableViewDataSource, UITableViewDelegate {
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
    currentCell.detailsLabel.text = values.value as? String

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
    /** Discussion
     * Setting the background color on UITableViewHeaderFooterView has been deprecated, BUT contentView.backgroundColor was not working on the IPOD or IPHONE-5/s
     * so we kept both until 'contentView.backgroundColor' work 100% on all supported devices
     */
    sectionView?.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    if let imagebg = ThemeManager.shared.currentTheme.colorNumber2().image(size: CGSize(width: sectionView?.frame.width ?? 0.0, height: sectionView?.frame.height ?? 0.0)) {
      sectionView?.backgroundView = UIImageView(image: imagebg)
    }

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
