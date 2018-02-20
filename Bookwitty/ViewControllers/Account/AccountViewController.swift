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
  @IBOutlet private weak var displayNameLabel: TTTAttributedLabel!

  fileprivate let viewModel = AccountViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.title = Strings.account()
    initializeComponents()
    applyTheme()
    fillUserInformation()
    addObservers()
    self.tabBarItem.title = Strings.me().uppercased()
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Account)
  }

  private func initializeComponents() {
    self.headerView.layoutMargins.left = ThemeManager.shared.currentTheme.generalExternalMargin()
    self.headerView.layoutMargins.right = ThemeManager.shared.currentTheme.generalExternalMargin()
    self.displayNameLabel.font = FontDynamicType.subheadline.font

    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  private func addObservers() {
    observeLanguageChanges()
    observeUserPenNamesChanges()
  }

  private func fillUserInformation() {
    let values = viewModel.headerInformation()
    self.displayNameLabel.text = values.name
  }

  fileprivate func dispatchSelectionAt(_ indexPath: IndexPath) {
    switch indexPath.section {
    case AccountViewModel.Sections.UserInformation.rawValue:
      switch indexPath.row {
      case 0:
        pushSettingsViewController()
      default:
        break
      }
    case AccountViewModel.Sections.PenNames.rawValue:
      switch indexPath.row % viewModel.numberOfRowsPerPenName {
      case 0:
        pushProfileViewController(indexPath: indexPath)
      case 1:
        pushPenNameViewController(indexPath: indexPath)
      default:
        break
      }
    case AccountViewModel.Sections.CreatePenNames.rawValue:
      pushPenNameViewController()
    case AccountViewModel.Sections.CustomerService.rawValue:
      switch indexPath.row {
      case 0:
        openHelpInBrowser()
      default:
        break
      }
    default:
      break
    }
  }

  func pushProfileViewController(indexPath: IndexPath) {
    guard let penName = viewModel.selectedPenName(atRow: indexPath.row) else {
      return
    }

    pushProfileViewController(penName: penName)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .GoToPenName,
                                                 name: penName.name ?? "")
    Analytics.shared.send(event: event)
  }

  func pushSettingsViewController() {
    let settingsViewController = Storyboard.Account.instantiate(SettingsViewController.self)
    navigationController?.pushViewController(settingsViewController, animated: true)
  }

  func pushPenNameViewController(indexPath: IndexPath? = nil) {
    let penNameViewController = Storyboard.Access.instantiate(PenNameViewController.self)
    var mode: PenNameViewController.Mode = .New
    if let indexPath = indexPath {
      let penName = viewModel.selectedPenName(atRow: indexPath.row)
      penNameViewController.viewModel.initializeWith(penName: penName, andUser: UserManager.shared.signedInUser)
      mode = .Edit
    }
    penNameViewController.mode = mode
    penNameViewController.showNoteLabel = false
    navigationController?.pushViewController(penNameViewController, animated: true)
  }

  func openHelpInBrowser() {
    let helpUrl: String
    switch GeneralSettings.sharedInstance.preferredLanguage {
    case Localization.Language.French.rawValue:
      helpUrl = "https://support.bookwitty.com/hc/fr-fr"
    case Localization.Language.English.rawValue: fallthrough
    default:
      helpUrl = "https://support.bookwitty.com/hc/en-us"
    }

    if let url = URL(string: helpUrl) {
      UIApplication.shared.openURL(url)

      //MARK: [Analytics] Screen Name
      Analytics.shared.send(screenName: Analytics.ScreenNames.Help)
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

    if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section, 0 == (indexPath.row % viewModel.numberOfRowsPerPenName) {
      reuseIdentifier = AccountPenNameTableViewCell.reuseIdentifier
    } else {
      reuseIdentifier = DisclosureTableViewCell.identifier
    }

    return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = viewModel.values(forRowAt: indexPath)

    if case AccountViewModel.Sections.PenNames.rawValue = indexPath.section, 0 == (indexPath.row % viewModel.numberOfRowsPerPenName) {
      guard let currentCell = cell as? AccountPenNameTableViewCell else {
        return
      }

      currentCell.label.text = values.title
      currentCell.profileImageView.sd_setImage(with: URL(string: values.imageUrl ?? ""), placeholderImage: ThemeManager.shared.currentTheme.penNamePlaceholder)
      currentCell.disclosureIndicatorImageView.isHidden = true

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
    /** Discussion
     * Setting the background color on UITableViewHeaderFooterView has been deprecated, BUT contentView.backgroundColor was not working on the IPOD or IPHONE-5/s
     * so we kept both until 'contentView.backgroundColor' work 100% on all supported devices
     */
    sectionView?.contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    if let imagebg = ThemeManager.shared.currentTheme.colorNumber2().image(size: CGSize(width: sectionView?.frame.width ?? 0.0, height: sectionView?.frame.height ?? 0.0)) {
      sectionView?.backgroundView = UIImageView(image: imagebg)
    }

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

//MARK: - Localizable implementation
extension AccountViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.account()
    tabBarItem.title = Strings.me().uppercased()
    viewModel.fillSectionTitles()
    tableView.reloadData()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

//MARK: - User & Pen Names updates
extension AccountViewController {
  fileprivate func observeUserPenNamesChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(userPenNamesChanged(notification:)), name: UserManager.Notifications.Name.UpdatePenNames, object: nil)
  }

  @objc
  fileprivate func userPenNamesChanged(notification: Notification) {
    tableView.reloadData()
  }
}

