//
//  FormatEditionsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol FormatEditionsViewControllerDelegate {
  func formatEditions(_ viewController: FormatEditionsViewController, selected editionId: String)
}

class FormatEditionsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  var viewModel = FormatEditionsViewModel()
  
  var delegate: FormatEditionsViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.FormatEditions)
    
    initializeComponents()
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
  
  private func initializeComponents() {
    // Configurae activity indicator
    activityIndicator.activityIndicatorViewStyle = .white
    activityIndicator.color = UIColor.bwRuby
    activityIndicator.hidesWhenStopped = true
    activityIndicator.backgroundColor = UIColor.clear
    activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
  }
  
  fileprivate func reloadTable() {
    self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
  }
  
  func showActivityIndicator() {
    tableView.tableFooterView = activityIndicator
    activityIndicator.startAnimating()
  }
  
  func hideActivityIndicator() {
    activityIndicator.stopAnimating()
    tableView.tableFooterView = UIView(frame: CGRect.zero)
  }
}

extension FormatEditionsViewController {
  fileprivate func reloadData() {
    showActivityIndicator()
    viewModel.loadData { (success, error) in
      self.hideActivityIndicator()
      self.reloadTable()
      self.loadNextPage()
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
    
    guard let editionId = viewModel.valueForRow(at: indexPath)?.id else {
      return
    }
    delegate?.formatEditions(self, selected: editionId)
  }
}

// MARK: - Pagination
extension FormatEditionsViewController {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
      loadNextPage()
    }
  }
  
  fileprivate func loadNextPage() {
    if viewModel.hasNextPage && !viewModel.isLoadingData {
      showActivityIndicator()
      self.viewModel.loadNextPage(completion: {
        (success, _) in
        self.hideActivityIndicator()
        guard success else {
          return
        }
        self.reloadTable()
      })
    }
  }
}
