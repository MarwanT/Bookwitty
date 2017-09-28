//
//  RichBookViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol RichBookViewControllerDelegate: class {
  func richBookViewController(_ richBookViewController: RichBookViewController, didSelect book: Book)
}

final class RichBookViewController: ASViewController<ASCollectionNode> {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let loaderNode: LoaderNode
  let misfortuneNode: MisfortuneNode
  let filterNode: FilterCellNode
  let viewModel = RichBookViewModel()
  weak var delegate: RichBookViewControllerDelegate?
  var loadingStatus: LoadingStatus = .none {
    didSet {
      var showLoader: Bool = false
      switch (loadingStatus) {
      case .none:
        showLoader = true
      default:
        showLoader = false
      }
      loaderNode.updateLoaderVisibility(show: showLoader)
    }
  }
  var shouldShowLoader: Bool {
    return (loadingStatus != .none)
  }
  var shouldDisplayMisfortuneNode: Bool {
    guard let misfortuneMode = viewModel.misfortuneNodeMode, !shouldShowLoader else {
      return false
    }
    misfortuneNode.mode = misfortuneMode
    return true
  }
  
  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
    misfortuneNode.style.height = ASDimensionMake(0)
    misfortuneNode.style.width = ASDimensionMake(0)
    
    filterNode = FilterCellNode()
    filterNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    
    super.init(node: collectionNode)
    
    misfortuneNode.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionNode.dataSource = self
    collectionNode.delegate = self
    self.view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    self.hideNavigationShadowImage()
    loadNavigationBarButtons()
  }
  
  private func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    
    let cancel = UIBarButtonItem(title: Strings.cancel(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.cancel(_:)))
    cancel.tintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    navigationItem.leftBarButtonItem = cancel
  }
  
  @objc private func cancel(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func hideNavigationShadowImage() {
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
  }
  
  private func addSeparatorBelow(_ view:UIView) {
    let  separator = UIView()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    self.view.addAutoLayoutSubview(separator)
    //Constraints
    separator.addHeightConstraint(1)
    self.view.addSiblingVerticalContiguous(top: view, bottom: separator, value: 0)
    self.view.addParentLeadingConstraint(separator)
    self.view.addParentTrailingConstraint(separator)
  }

  
  func nodeForItem(atIndexPath indexPath: IndexPath) -> BaseCardPostNode? {
    guard let resource = self.viewModel.resourceForIndex(indexPath: indexPath) else {
      return nil
    }
    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }
  
  func searchAction() {
    loadingStatus = .loading
    viewModel.clearSearchData()
    updateCollection(reloadAll: true)
    
    let query = viewModel.filter.query ?? ""
    viewModel.search(query: query) { (success, error) in
      self.loadingStatus = .none
      self.updateCollection(with: nil, loaderSection: true, dataSection: true)
    }
  }
}

extension RichBookViewController: UISearchBarDelegate {
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    return true
  }
  
  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
  
  public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    if viewModel.filter.query != searchBar.text {
      searchBar.text = viewModel.filter.query
    }
    return true
  }
  
  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    /* Discussion:
     * Reset the filters when the query is new
     */
    if viewModel.filter.query != searchBar.text {
      viewModel.filter.query = searchBar.text
    }
    searchAction()
    searchBar.resignFirstResponder()
  }
  
  public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = viewModel.filter.query
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
  }
}

// MARK: - Declarations
extension RichBookViewController {
  enum Section: Int {
    case cards = 0
    case activityIndicator
    case misfortune
    
    static var numberOfSections: Int {
      return 3
    }
  }
}


// MARK: - Misfortune node delegate
extension RichBookViewController: MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?) {
    guard let action = action else {
      return
    }
    
    switch action {
    case .tryAgain:
      searchAction()
    case .settings:
      AppDelegate.openSettings()
    default:
      break
    }
  }
}

// MARK: - ASCollectionDataSource/Delegate
extension RichBookViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {

    if section == Section.activityIndicator.rawValue {
      return shouldShowLoader ? 1 : 0
    } else if section == Section.misfortune.rawValue {
      return shouldDisplayMisfortuneNode ? 1 : 0
    } else {
      return viewModel.numberOfItemsInSection(section: section)
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let indexPath = indexPath
    
    return {
      if indexPath.section == Section.activityIndicator.rawValue {
        //Return the activity indicator
        return self.loaderNode
      } else if indexPath.section == Section.misfortune.rawValue {
        return self.misfortuneNode
      } else {
        let baseCardNode = self.nodeForItem(atIndexPath: indexPath) ?? BaseCardPostNode()
        return baseCardNode
      }
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: !(loadingStatus == .none))
    } else if node is MisfortuneNode {
      misfortuneNode.mode = viewModel.misfortuneNodeMode ?? MisfortuneNode.Mode.empty
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(indexPath: indexPath), let commonResource =  resource as? ModelCommonProperties else {
          return
      }
      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
    }
  }
}

extension RichBookViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {    
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath) as? Book else {
      return
    }
    
    let bookDetailsViewController = BookDetailsViewController()
    bookDetailsViewController.mode = .select
    bookDetailsViewController.delegate = self
    bookDetailsViewController.initialize(with: resource)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)    
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
  
  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage()
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }
    guard loadingStatus == .none else {
      context.completeBatchFetching(true)
      return
    }
    context.beginBatchFetching()
    self.loadingStatus = .loadMore
    DispatchQueue.main.async {
      self.updateCollection(with: nil, loaderSection: true, dataSection: false)
    }
    
    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cards.rawValue)
    
    //MARK: [Analytics] Event
    //TODO: Grab the query from the search bar
    let query = ""
    let event: Analytics.Event = Analytics.Event(category: .Search,
                                                 action: .LoadMore,
                                                 name: query)
    Analytics.shared.send(event: event)
    
    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      var updatedIndexPathRange: [IndexPath]? = nil
      defer {
        self?.loadingStatus = .none
        self?.updateCollection(with: updatedIndexPathRange, loaderSection: true, completionBlock: nil)
        context.completeBatchFetching(true)
      }

      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection(section: Section.cards.rawValue)
      
      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath
        
        updatedIndexPathRange = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cards.rawValue)
        })
      }
    }
  }
}

extension RichBookViewController {
  func updateCollectionNodes(indexPathForAffectedItems: [IndexPath]) {
    let cards = indexPathForAffectedItems.map({ collectionNode.nodeForItem(at: $0) })
    cards.forEach({ card in
      guard let card = card as? BaseCardPostNode else {
        return
      }
      guard let indexPath = card.indexPath, let commonResource =  viewModel.resourceForIndex(indexPath: indexPath) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = commonResource
    })
  }
  
  func updateCollection(reloadAll: Bool = false, with itemIndices: [IndexPath]? = nil, reloadItemsWithIndices: Bool = false, loaderSection: Bool = false, dataSection: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData()
    } else {
      collectionNode.performBatchUpdates({
        // Always relaod misfortune section
        collectionNode.reloadSections(IndexSet(integer: Section.misfortune.rawValue))
        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if dataSection {
          collectionNode.reloadSections(IndexSet(integer: Section.cards.rawValue))
        } else if let itemIndices = itemIndices {
          if reloadItemsWithIndices {
            collectionNode.reloadItems(at: itemIndices)
          } else {
            collectionNode.insertItems(at: itemIndices)
          }
        }
      }, completion: completionBlock)
    }
  }
}

extension RichBookViewController: BookDetailsViewControllerDelegate {
  func bookDetails(viewController: BookDetailsViewController, didSelect book: Book) {
    _ = self.navigationController?.popViewController(animated: true)
    self.delegate?.richBookViewController(self, didSelect: book)
  }
}
