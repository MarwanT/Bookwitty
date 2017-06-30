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
  }
  
  func initialize(initialProductIdentifier: String, productForm: ProductForm) {
    viewModel.initialize(initialProductIdentifier: initialProductIdentifier, productForm: productForm)
  }
  
  private func initializeTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  fileprivate func reloadTable() {
    self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
  }
}

// MARK: - FormatEditionsViewController
extension FormatEditionsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
