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
    tableView.separatorInset.left = ThemeManager.shared.currentTheme.generalExternalMargin()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    reloadData()
  }
  
  fileprivate func reloadData() {
    viewModel.loadData { (success, error) in
      self.tableView.reloadData()
    }
  }
  
  func initialize(with book: Book) {
    self.viewModel.initialize(with: book)
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
      return UITableViewCell()
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
}
