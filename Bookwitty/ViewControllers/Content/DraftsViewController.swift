//
//  DraftsViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/13.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol DraftsViewControllerDelegate: class {
  func drafts(viewController: DraftsViewController, didRequestEdit draft: CandidatePost)
  func draftsViewControllerRequestClose(_ viewController: DraftsViewController)
}

class DraftsViewController: ASViewController<ASTableNode> {

  fileprivate let tableNode: ASTableNode

  fileprivate let loaderNode: LoaderNode
  fileprivate var loadingStatus: LoadingStatus = .none

  fileprivate let refreshController: UIRefreshControl

  let viewModel = DraftsViewModel()

  weak var delegate: DraftsViewControllerDelegate? = nil

  init() {
    loaderNode = LoaderNode()
    refreshController = UIRefreshControl()

    tableNode = ASTableNode()
    super.init(node: tableNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()
    setupNavigationBarButtons()
    applyTheme()
    loadDrafts()

    tableNode.view.addSubview(refreshController)
    refreshController.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
  }

  fileprivate func initializeComponents() {
    title = Strings.drafts()
    tableNode.delegate = self
    tableNode.dataSource = self
    tableNode.view.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }

  fileprivate func setupNavigationBarButtons() {
    let closeBarButtonItem = UIBarButtonItem(title: Strings.close(),
                                           style: .plain,
                                           target: self,
                                           action: #selector(closeBarButtonTouchUpInside(_:)))

    navigationItem.leftBarButtonItem = closeBarButtonItem

    var attributes = closeBarButtonItem.titleTextAttributes(for: .normal) ?? [:]
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    attributes[NSForegroundColorAttributeName] = defaultTextColor
    closeBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
  }

  fileprivate func loadDrafts() {
    loadingStatus = .loading
    viewModel.loadDrafts { (success: Bool, error: BookwittyAPIError?) in
      self.loadingStatus = .none
      self.tableNode.reloadData()

      if self.refreshController.isRefreshing {
        self.refreshController.endRefreshing()
      }
    }
  }

  fileprivate func showDeleteConfirmationAlert(completion: @escaping (_ confirmed: Bool)->()) {
    let message = Strings.delete_draft_confirmation_message()
    let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.delete(), style: .destructive, handler: { (action: UIAlertAction) in
      completion(true)
    }))

    alert.addAction(UIAlertAction(title: Strings.cancel(), style: .cancel, handler: { (action: UIAlertAction) in
      completion(false)
    }))
    self.present(alert, animated: true, completion: nil)
  }
}

//MARK: - Actions
extension DraftsViewController {
  @objc fileprivate func closeBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    delegate?.draftsViewControllerRequestClose(self)
  }
}

//MARK: - Enum declarations
extension DraftsViewController {
  //Collection Node Sections
  enum Section: Int {
    case drafts
    case activityIndicator

    static let count: Int = 2
  }

  //Loader node loading statuses
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  var showLoader: Bool {
    return loadingStatus != .none
  }
}

extension DraftsViewController: Themeable {
  func applyTheme() {
    tableNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

//MARK: -
extension DraftsViewController {
  @objc
  fileprivate func pullToRefresh() {
    guard refreshController.isRefreshing else {
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }

    guard loadingStatus == .none else {
      refreshController.endRefreshing()
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }

    self.loadingStatus = .reloading
    self.refreshController.beginRefreshing()
    loadDrafts()
  }
}

extension DraftsViewController: ASTableDataSource, ASTableDelegate {
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return Section.count
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else {
      return 0
    }

    switch section {
    case .drafts:
      return viewModel.numberOfRows()
    case .activityIndicator:
      return showLoader ? 1 : 0
    }
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      guard let section = Section(rawValue: indexPath.section) else {
        return ASCellNode()
      }

      switch section {
      case .drafts:
        let values = self.viewModel.values(for: indexPath.item)
        let draftNode = DraftNode()
        draftNode.title = values.title
        draftNode.updatedAt = values.lastUpdated
        draftNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

        return draftNode
      case .activityIndicator:
        return self.loaderNode
      }
    }
  }

  func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: showLoader)
    }
  }

  func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: tableNode.frame.width, height: 0),
      max: CGSize(width: tableNode.frame.width, height: 50.0)
    )
  }

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)

    guard viewModel.values(for: indexPath.row).editable else {
      self.showAlertWith(title: "", message: Strings.editing_not_yet_supported())
      return
    }

    guard let candidate = self.viewModel.resource(at: indexPath.row) as? CandidatePost else {
      return
    }
    
    delegate?.drafts(viewController: self, didRequestEdit: candidate)
  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }

  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return Strings.delete()
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    viewModel.deleteDraft(at: indexPath.row) { (success: Bool, error: BookwittyAPIError?) in
      guard success else {
        return
      }

      self.tableNode.deleteRows(at: [indexPath], with: .automatic)
    }
  }

  func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
    return viewModel.hasNextPage()
  }

  func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }

    guard loadingStatus == .none else {
      context.completeBatchFetching(true)
      return
    }

    self.loadingStatus = .loadMore
    DispatchQueue.main.async {
      tableNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue), with: .automatic)
    }

    context.beginBatchFetching()

    viewModel.loadNext { (sucess: Bool) in
      self.loadingStatus = .none
      tableNode.reloadData()
      context.completeBatchFetching(true)
    }
  }
}
