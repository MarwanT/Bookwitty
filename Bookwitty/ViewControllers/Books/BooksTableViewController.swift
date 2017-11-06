//
//  BooksTableViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class BooksTableViewController: UITableViewController {
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  var viewModel = BooksTableViewModel()
  
  func initialize(with books: [Book]?, loadingMode: DataLoadingMode?) {
    viewModel.initialize(with: books, loadingMode: loadingMode)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.register(BookTableViewCell.nib, forCellReuseIdentifier: BookTableViewCell.reuseIdentifier)
    
    initializeComponents()
    observeLanguageChanges()
    applyLocalization()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BooksListing)
  }
  
  private func initializeComponents() {
    activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(for: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.reuseIdentifier) ?? UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? BookTableViewCell else {
      return
    }
    let values = viewModel.selectionValues(for: indexPath)
    cell.productImageURL = values.imageURL
    cell.bookTitle = values.bookTitle
    cell.authorName = values.authorName
    cell.productType = values.productType
    cell.price = values.price
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return BookTableViewCell.minimumHeight
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let book = viewModel.book(for: indexPath) else {
      return
    }
    pushBookDetailsViewController(with: book)
  }
  
  fileprivate func pushBookDetailsViewController(with book: Book) {
    guard !book.isPandacraft else {
      if let url = book.canonicalURL {
        WebViewController.present(url: url)
      }
      return
    }
    let bookDetailsViewController = BookDetailsViewController()
    bookDetailsViewController.initialize(with: book)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }
}


// MARK: - Pagination
extension BooksTableViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
      if viewModel.hasNextPage && !viewModel.isLoadingNextPage {
        showActivityIndicator()
        self.viewModel.loadNextPage(completion: {
          (success) in
          self.hideActivityIndicator()
          guard success else {
            return
          }
          self.tableView.reloadData()
        })
      }
    }
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

extension BooksTableViewController {
  enum DataLoadingMode {
    case local(paginator: Paginator)
    case server(nextPageURL: URL?)
  }
}

//MARK: - Localizable implementation
extension BooksTableViewController: Localizable {
  func applyLocalization() {
    title = Strings.books()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
