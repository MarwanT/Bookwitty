//
//  SelectPenNameViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/05.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol SelectPenNameViewControllerDelegate: class {
  func selectPenName(controller: SelectPenNameViewController, didSelect penName: PenName?)
}

class SelectPenNameViewController: UIViewController {

  let viewModel = SelectPenNameViewModel()

  @IBOutlet weak var tableView: UITableView!

  weak var delegate: SelectPenNameViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()
  }

  fileprivate func initializeComponents() {
    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    let doneBarButtonItem = UIBarButtonItem(title: Strings.done(),
                                           style: .plain,
                                           target: self,
                                           action: #selector(doneBarButtonTouchUpInside(_:)))
    navigationItem.rightBarButtonItem = doneBarButtonItem

    setTextAppearanceState(of: doneBarButtonItem)
  }

  fileprivate func setTextAppearanceState(of barButtonItem: UIBarButtonItem) -> Void {
    var attributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    attributes[NSForegroundColorAttributeName] = defaultTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .normal)

    let grayedTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    attributes[NSForegroundColorAttributeName] = grayedTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .disabled)
  }
}

extension SelectPenNameViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

//MARK: - Actions
extension SelectPenNameViewController {
  @objc fileprivate func doneBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    //TODO: Empty Implementation
  }
}

//MARK: - UITableViewDataSource, UITableViewDelegate implementation
extension SelectPenNameViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: AccountPenNameTableViewCell.reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let values = viewModel.values(for: indexPath.row)
    guard let currentCell = cell as? AccountPenNameTableViewCell else {
      return
    }

    currentCell.label.text = values.title
    currentCell.profileImageView.sd_setImage(with: URL(string: values.imageUrl ?? ""), placeholderImage: ThemeManager.shared.currentTheme.penNamePlaceholder)
    currentCell.disclosureIndicatorImageView.isHidden = !values.selected
    if values.selected {
      currentCell.disclosureIndicatorImageView.image = #imageLiteral(resourceName: "tick")
      currentCell.disclosureIndicatorImageView.tintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.toggleSelection(at: indexPath.row)
    tableView.reloadData()
  }
}
