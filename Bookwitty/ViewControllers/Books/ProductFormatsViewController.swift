//
//  ProductFormatsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ProductFormatsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate var viewModel = ProductFormatsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ProductFormats)
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.register(PreferredFormatTableViewCell.nib, forCellReuseIdentifier: PreferredFormatTableViewCell.reuseIdentifier)
    tableView.register(UniColorSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: UniColorSectionHeaderView.reuseIdentifier)
    tableView.register(CollapsableTableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: CollapsableTableViewSectionHeaderView.reuseIdentifier)
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    
    tableView.separatorInset.left = ThemeManager.shared.currentTheme.generalExternalMargin()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    reloadData()
  }
  
  fileprivate func reloadData() {
    viewModel.loadData { (success, error) in
      self.refreshTableView()
    }
  }
  
  func initialize(with book: Book) {
    self.viewModel.initialize(with: book)
  }
  
  fileprivate func refreshTableView() {
    let sections = [
      Section.preferredFormats,
      Section.availableFormats,
      Section.activityIndicator
    ]
    
    let mutableIndexSet = NSMutableIndexSet()
    sections.forEach({ mutableIndexSet.add($0.rawValue) })
    tableView.reloadSections(mutableIndexSet as IndexSet, with: UITableViewRowAnimation.none)
  }
}

// MARK: Declare Section
extension ProductFormatsViewController {
  enum Section: Int {
    case preferredFormats = 0
    case availableFormats
    case activityIndicator
    
    static var numberOfSections: Int {
      return 3
    }
  }
}

// MARK: Table View Delegates
extension ProductFormatsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: indexPath.section) else {
      return UITableViewCell()
    }
    
    switch section {
    case .preferredFormats:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: PreferredFormatTableViewCell.reuseIdentifier, for: indexPath) as? PreferredFormatTableViewCell, let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.PreferredFormatValues else {
        return UITableViewCell()
      }
      cell.primaryLabel.text = values.form.value
      cell.secondaryLabel.text = values.price?.formattedValue
      if values.isSelected {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
      }
      return cell
    case .availableFormats:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier, for: indexPath) as? DisclosureTableViewCell, let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.AvailableFormatValues else {
        return UITableViewCell()
      }
      cell.label.text = "\(values.form.value) (\(values.numberOfEditions))"
      return cell
    case .activityIndicator:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else {
      return
    }
    
    switch section {
    case .preferredFormats:
      viewModel.selectPreferredFormat(indexPath)
    case .availableFormats:
      break
    case .activityIndicator:
      break
    }
  }
  
  
  // Headers $ Footers
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let values = viewModel.sectionValues(for: section), let section = Section(rawValue: section) else {
      return nil
    }
    
    switch section {
    case .preferredFormats:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UniColorSectionHeaderView.reuseIdentifier) else {
        return nil
      }
      headerView.textLabel?.text = values as? String
      return headerView
    case .availableFormats:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CollapsableTableViewSectionHeaderView.reuseIdentifier) as? CollapsableTableViewSectionHeaderView, let values = values as? ProductFormatsViewModel.AvailableFormatHeaderValues else {
        return nil
      }
      headerView.configuration.titleLabelTextColor = ThemeManager.shared.currentTheme.defaultECommerceColor()
      headerView.configuration.contentLayoutMargin.right = 2
      headerView.mode = values.mode
      headerView.titleLabel.text = values.title
      headerView.subTitleLabel.text = nil
      headerView.section = section.rawValue
      headerView.delegate = self
      return headerView
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard viewModel.sectionValues(for: section) != nil, let section = Section(rawValue: section) else {
      return 0
    }
    
    switch section {
    case .preferredFormats:
      return 50
    case .availableFormats:
      return 50.0
    default:
      return 0.0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
}

extension ProductFormatsViewController: CollapsableTableViewSectionHeaderViewDelegate {
  func sectionHeader(view: CollapsableTableViewSectionHeaderView, request mode: CollapsableTableViewSectionHeaderView.Mode) {
    guard let rawSection = view.section else {
      return
    }
    
    viewModel.toggleSection()
    tableView.reloadSections(IndexSet(integer: rawSection), with: .none)
  }
}
