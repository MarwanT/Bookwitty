//
//  FormatEditionsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class FormatEditionsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var viewModel = FormatEditionsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initializeTableView()
    
    reloadData()
  }
  
  func initialize(initialProductIdentifier: String, productForm: ProductForm) {
    viewModel.initialize(initialProductIdentifier: initialProductIdentifier, productForm: productForm)
  }
  
  private func initializeTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 40
    
    tableView.layoutMargins = UIEdgeInsets.zero
  }
  
  fileprivate func reloadTable() {
    self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
  }
}

extension FormatEditionsViewController {
  fileprivate func reloadData() {
    viewModel.loadData { (success, error) in
      self.reloadTable()
    }
  }
}

// MARK: - FormatEditionsViewController
extension FormatEditionsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: FormatEditionTableViewCell.reuseIdentifier, for: indexPath) as? FormatEditionTableViewCell, let value = viewModel.valueForRow(at: indexPath) else {
      return UITableViewCell()
    }
    cell.leftTextLabel?.text = value.description
    cell.rightTextLabel?.text = value.formattedPrice
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
