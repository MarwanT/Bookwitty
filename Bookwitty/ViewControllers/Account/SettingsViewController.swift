//
//  SettingsViewController.swift
//  Bookwitty
//
//  Created by charles on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import EMCCountryPickerController

class SettingsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  fileprivate let viewModel = SettingsViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    setupNavigationBarButtons()
    applyTheme()
    
    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Settings)
  }

  private func initializeComponents() {
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  private func setupNavigationBarButtons() {
    
  }

  fileprivate func dispatchSelectionAt(_ indexPath: IndexPath) {
    switch indexPath.section {
    case SettingsViewModel.Sections.General.rawValue:
      switch indexPath.row {
      case 0: //email
        pushEmailSettingsViewController()
      case 1: //newsletter
        break
      case 2: //change password
        pushChangePasswordViewController()
      case 3:
        presentChangeLanguageActionSheet()
      case 4: //country/region
        pushCountryPickerViewController()
      default:
        break
      }
    case SettingsViewModel.Sections.SignOut.rawValue: //sign out
      signOut()
    default:
      break
    }
  }

  private func pushEmailSettingsViewController() {
    let viewController = Storyboard.Account.instantiate(EmailSettingsViewController.self)
    self.navigationController?.pushViewController(viewController, animated: true)
  }

  private func pushChangePasswordViewController() {
    let viewController = Storyboard.Account.instantiate(ChangePasswordViewController.self)
    self.navigationController?.pushViewController(viewController, animated: true)
  }

  private func pushCountryPickerViewController() {
    let countryPickerViewController: EMCCountryPickerController = EMCCountryPickerController()
    countryPickerViewController.labelFont = FontDynamicType.caption2.font
    countryPickerViewController.countryNameDisplayLocale = Locale.application
    countryPickerViewController.flagSize = 35

    countryPickerViewController.onCountrySelected = { country in
      guard let country = country else {
        return
      }

      let _ = countryPickerViewController.navigationController?.popViewController(animated: true)      
      self.viewModel.updateUserCountry(country: country.countryCode, completion: {
        (success: Bool) in
        self.tableView.reloadData()
      })
    }

    self.navigationController?.pushViewController(countryPickerViewController, animated: true)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.CountryList)
  }

  private func presentChangeLanguageActionSheet() {
    let alertController = UIAlertController(title: Strings.language(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    let languages: [Localization.Language] = Localization.Language.all()
    languages.forEach { (language: Localization.Language) in
      let languageDisplayName: String = Locale.application.localizedString(forLanguageCode: language.rawValue) ?? language.rawValue
      alertController.addAction(UIAlertAction(title: languageDisplayName.capitalized, style: UIAlertActionStyle.default, handler: {
        (action: UIAlertAction) in
        Localization.set(language: language)
      }))
    }
    alertController.addAction(UIAlertAction(title: Strings.cancel(), style: UIAlertActionStyle.cancel, handler: nil))
    navigationController?.present(alertController, animated: true, completion: nil)
  }

  private func signOut() {
    _ = navigationController?.popToRootViewController(animated: true)
    NotificationCenter.default.post(name: AppNotification.signOut, object: nil)
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
    currentCell.detailsLabel.text = values.value as? String

    let accessory = viewModel.accessory(forRowAt: indexPath)

    var hideDiclosure = true
    switch accessory {
    case .Disclosure:
      hideDiclosure = false
    case .Switch:
      break
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
    dispatchSelectionAt(indexPath)
  }
}

//MARK: - Localizable implementation
extension SettingsViewController: Localizable {
  func applyLocalization() {
    title = Strings.settings()
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
