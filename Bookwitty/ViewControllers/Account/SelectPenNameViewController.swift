//
//  SelectPenNameViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/05.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SelectPenNameViewController: UIViewController {

  fileprivate let viewModel = SelectPenNameViewModel()

  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }
}

extension SelectPenNameViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
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
