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

  enum Sections: Int {
    case list
    case new

    static let count: Int = 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()

    title = PenName.resourceType.localizedName
  }

  fileprivate func initializeComponents() {
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    tableView.register(TableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)

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

  fileprivate func pushPenNameViewController() {
    let penNameViewController = Storyboard.Access.instantiate(PenNameViewController.self)
    penNameViewController.mode = .New
    penNameViewController.showNoteLabel = false
    penNameViewController.delegate = self
    navigationController?.pushViewController(penNameViewController, animated: true)
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
    self.delegate?.selectPenName(controller: self, didSelect: viewModel.selectedPenName)
  }
}

//MARK: - UITableViewDataSource, UITableViewDelegate implementation
extension SelectPenNameViewController: UITableViewDataSource, UITableViewDelegate {

  func numberOfSections(in tableView: UITableView) -> Int {
    return Sections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = SelectPenNameViewController.Sections(rawValue: indexPath.section) else {
      return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

    var reuseIdentifier: String
    switch section {
    case .list:
      reuseIdentifier = AccountPenNameTableViewCell.reuseIdentifier
    case .new:
      reuseIdentifier = DisclosureTableViewCell.identifier
    }

    return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.selectionStyle = .none

    guard let section = SelectPenNameViewController.Sections(rawValue: indexPath.section) else {
      return
    }

    switch section {
    case .list:
      guard let currentCell = cell as? AccountPenNameTableViewCell else {
        return
      }

      let values = viewModel.values(for: indexPath.row)
      currentCell.label.text = values.title
      currentCell.profileImageView.sd_setImage(with: URL(string: values.imageUrl ?? ""), placeholderImage: ThemeManager.shared.currentTheme.penNamePlaceholder)
      currentCell.disclosureIndicatorImageView.isHidden = !values.selected
      if values.selected {
        currentCell.disclosureIndicatorImageView.image = #imageLiteral(resourceName: "tick")
        currentCell.disclosureIndicatorImageView.tintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
      }
    case .new:
      guard let currentCell = cell as? DisclosureTableViewCell else {
        return
      }

      currentCell.label.font = FontDynamicType.caption1.font
      currentCell.label.text = Strings.create_new_pen_name()
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let section = SelectPenNameViewController.Sections(rawValue: indexPath.section) else {
      return
    }

    switch section {
    case .list:
      viewModel.selectPenName(at: indexPath.row)
      tableView.reloadData()
    case .new:
      pushPenNameViewController()
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSectionHeaderView.reuseIdentifier) as? TableViewSectionHeaderView
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
    guard let section = SelectPenNameViewController.Sections(rawValue: section),
    case .new = section else {
      return 0.0
    }

    return 15.0
  }
}

extension SelectPenNameViewController: PenNameViewControllerDelegate {
  func penName(viewController: PenNameViewController, didFinish: PenNameViewController.Mode, with penName: PenName?) {
    guard let penName = penName else {
      return
    }

    viewModel.reloadData()
    viewModel.preselect(penName: penName)
    tableView.reloadData()
  }
}
