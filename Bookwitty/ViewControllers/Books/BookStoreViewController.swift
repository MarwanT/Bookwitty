//
//  BookStoreViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

class BookStoreViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  
  let banner = BannerView()
  let featuredContentCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
  let bookwittySuggestsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let selectionTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let viewAllCategories = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllBooksView = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllSelectionsView = UIView.loadFromView(DisclosureView.self, owner: nil)
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  let viewModel = BookStoreViewModel()
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  fileprivate let sectionSpacing = ThemeManager.shared.currentTheme.sectionSpacing()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    viewModel.dataLoaded = viewModelLoadedDataBlock()
    
    initializeNavigationItems()
    initializeSubviews()
    
    refreshViewController()
  }
  
  private func initializeNavigationItems() {
    let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    leftNegativeSpacer.width = -10
    let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.settingsButtonTap(_:)))
    navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
  }
  
  private func initializeSubviews() {
    // Activity Indicator
    activityIndicator.constrainHeight("44")
    
    // Featured Content View
    let itemSize = FeaturedContentCollectionViewCell.defaultSize
    let interItemSpacing: CGFloat = 10
    let contentInset = UIEdgeInsets(
      top: 15, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 10, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
    flowLayout.itemSize = itemSize
    flowLayout.minimumInteritemSpacing = interItemSpacing
    featuredContentCollectionView.collectionViewLayout = flowLayout
    featuredContentCollectionView.register(FeaturedContentCollectionViewCell.nib, forCellWithReuseIdentifier: FeaturedContentCollectionViewCell.reuseIdentifier)
    featuredContentCollectionView.dataSource = self
    featuredContentCollectionView.delegate = self
    featuredContentCollectionView.backgroundColor = UIColor.clear
    featuredContentCollectionView.contentInset = contentInset
    featuredContentCollectionView.showsHorizontalScrollIndicator = false
    featuredContentCollectionView.constrainHeight("\(itemSize.height + contentInset.top + contentInset.bottom)")
    featuredContentCollectionView.constrainWidth("\(self.view.frame.width)")
    
    // View All Categories View
    viewAllCategories.configuration.style = .highlighted
    viewAllCategories.delegate = self
    viewAllCategories.label.text = viewModel.viewAllCategoriesLabelText
    viewAllCategories.constrainHeight("45")
    
    // Bookwitty Suggests View
    bookwittySuggestsTableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bookwittySuggestsTableView.separatorInset = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    bookwittySuggestsTableView.dataSource = self
    bookwittySuggestsTableView.delegate = self
    bookwittySuggestsTableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    
    // Book Selection View
    selectionTableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    selectionTableView.separatorInset = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    selectionTableView.dataSource = self
    selectionTableView.delegate = self
    selectionTableView.register(SectionTitleHeaderView.nib, forHeaderFooterViewReuseIdentifier: SectionTitleHeaderView.reuseIdentifier)
    selectionTableView.register(BookTableViewCell.nib, forCellReuseIdentifier: BookTableViewCell.reuseIdentifier)
  }
  
  private func viewModelLoadedDataBlock() -> (_ finished: Bool) -> Void {
    return { (finished: Bool) -> Void in
      self.loadUserInterface()
    }
  }
  
  private func refreshViewController() {
    
    // Clear All Subviews in stack view
    stackView.subviews.forEach({ $0.removeFromSuperview() })
    showLoader()
    viewModel.loadData { (success, error) in
      self.hideLoader()
      guard success else {
        // TODO: Display the bookwitty error view
        return
      }
      self.loadUserInterface()
    }
  }
  
  private func loadUserInterface() {
    loadBannerSection()
    loadFeaturedContentSection()
    loadViewAllCategories()
    loadBookwittySuggest()
    loadSelectionSection()
  }
  
  func loadBannerSection() {
    let canDisplayBanner = banner.superview == nil
    if viewModel.hasBanner && canDisplayBanner {
      banner.imageURL = viewModel.bannerImageURL
      banner.title = viewModel.bannerTitle
      banner.subtitle = viewModel.bannerSubtitle
      UIView.animate(withDuration: 2, animations: { 
        self.stackView.addArrangedSubview(self.banner)
      })
    }
  }
  
  func loadFeaturedContentSection() {
    let canDisplayFeaturedContent = featuredContentCollectionView.superview == nil
    if viewModel.hasFeaturedContent && canDisplayFeaturedContent {
      stackView.addArrangedSubview(featuredContentCollectionView)
    }
  }
  
  func loadViewAllCategories() {
    let canDisplayCategories = viewAllCategories.superview == nil
    if viewModel.hasCategories && canDisplayCategories {
      addSeparator(leftMargin)
      stackView.addArrangedSubview(viewAllCategories)
    }
  }
  
  func loadBookwittySuggest() {
    let canDisplayBookwittySuggest = bookwittySuggestsTableView.superview == nil
    if viewModel.hasBookwittySuggests && canDisplayBookwittySuggest {
      addSeparator()
      addSpacing(space: 10)
      stackView.addArrangedSubview(bookwittySuggestsTableView)
      bookwittySuggestsTableView.alignLeading("0", trailing: "0", toView: stackView)
      // Add the table view height constraint
      bookwittySuggestsTableView.layoutIfNeeded()
      bookwittySuggestsTableView.constrainHeight("\(bookwittySuggestsTableView.contentSize.height)")
    }
  }
  
  func loadSelectionSection() {
    let canDisplaySelection = selectionTableView.superview == nil
    if viewModel.hasSelectionSection && canDisplaySelection {
      addSeparator()
      addSpacing(space: sectionSpacing)
      stackView.addArrangedSubview(selectionTableView)
      selectionTableView.alignLeading("0", trailing: "0", toView: stackView)
      // Add the table view height constraint
      selectionTableView.layoutIfNeeded()
      selectionTableView.constrainHeight("\(selectionTableView.contentSize.height)")
    }
  }
  
  func addSeparator(_ leftMargin: CGFloat = 0) {
    let separatorView = separatorViewInstance()
    stackView.addArrangedSubview(separatorView)
    separatorView.alignLeadingEdge(withView: stackView, predicate: "\(leftMargin)")
    separatorView.alignTrailingEdge(withView: stackView, predicate: "0")
  }
  
  func addSpacing(space: CGFloat) {
    guard space > 0 else {
      return
    }
    
    let spacer = UIView(frame: CGRect.zero)
    spacer.backgroundColor = UIColor.clear
    spacer.constrainHeight("\(space)")
    stackView.addArrangedSubview(spacer)
  }
  
  fileprivate func separatorViewInstance() -> UIView {
    let separatorView = UIView(frame: CGRect.zero)
    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separatorView.constrainHeight("1")
    return separatorView
  }
  
  fileprivate func pushCategoriesViewController() {
    let categoriesViewController = Storyboard.Books.instantiate(CategoriesTableViewController.self)
    self.navigationController?.pushViewController(categoriesViewController, animated: true)
  }
  
  func showLoader() {
    activityIndicator.startAnimating()
    stackView.insertArrangedSubview(activityIndicator, at: 0)
    activityIndicator.alignLeading("0", trailing: "0", toView: stackView)
  }
  
  func hideLoader() {
    activityIndicator.stopAnimating()
    self.activityIndicator.removeFromSuperview()
  }
}

// MARK: - Action
extension BookStoreViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }
}

// MARK: - Featured Content Collection View data source

extension BookStoreViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.featuredContentNumberOfItems
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedContentCollectionViewCell.reuseIdentifier, for: indexPath) as? FeaturedContentCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    let data = viewModel.featuredContentValues(for: indexPath)
    cell.title = data.title
    cell.imageURL = data.imageURL
    return cell
  }
}

// MARK: Featured Content Collection View Delegate

extension BookStoreViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO: Handle featured content selection
  }
}

// MARK: - Table View Delegates

extension BookStoreViewController: UITableViewDataSource, UITableViewDelegate {
  
  // MARK: Table View Data Source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if tableView === bookwittySuggestsTableView {
      return viewModel.bookwittySuggestsNumberOfSections
    } else {
      return viewModel.selectionNumberOfSection
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView === bookwittySuggestsTableView {
      return viewModel.bookwittySuggestsNumberOfItems
    } else {
      return viewModel.selectionNumberOfItems
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView === bookwittySuggestsTableView {
      return tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier) ?? UITableViewCell()
    } else {
      return tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.reuseIdentifier) ?? UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if tableView === bookwittySuggestsTableView {
      guard let cell = cell as? DisclosureTableViewCell else {
        return
      }
      let value = viewModel.bookwittySuggestsValues(for: indexPath)
      cell.label.text = value
    } else {
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
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if tableView === bookwittySuggestsTableView {
      let containerView = UIView(frame: CGRect.zero)
      
      let tableHeaderLabel = UILabel(frame: CGRect.zero)
      tableHeaderLabel.text = viewModel.bookwittySuggestsTitle
      tableHeaderLabel.font = FontDynamicType.callout.font
      tableHeaderLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
      tableHeaderLabel.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
      containerView.addSubview(tableHeaderLabel)
      tableHeaderLabel.alignTop("0", leading: "\(leftMargin)", bottom: "0", trailing: "0", toView: containerView)
      
      let separatorView = separatorViewInstance()
      containerView.addSubview(separatorView)
      separatorView.alignBottomEdge(withView: containerView, predicate: "0")
      separatorView.alignLeading("\(leftMargin)", trailing: "0", toView: containerView)
      
      return containerView
    } else {
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionTitleHeaderView.reuseIdentifier) as? SectionTitleHeaderView else {
        return nil
      }
      headerView.label.text = viewModel.selectionHeaderTitle
      return headerView
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard tableView === selectionTableView else {
      return nil
    }
    
    viewAllBooksView.configuration.style = .highlighted
    viewAllBooksView.delegate = self
    viewAllBooksView.label.text = viewModel.viewAllBooksLabelText
    
    viewAllSelectionsView.configuration.style = .highlighted
    viewAllSelectionsView.delegate = self
    viewAllSelectionsView.label.text = viewModel.viewAllSelectionsLabelText
    
    let topSeparator = separatorViewInstance()
    let middleSeparator = separatorViewInstance()
    let bottomSeparator = separatorViewInstance()
    
    let containerView = UIView(frame: CGRect.zero)
    containerView.addSubview(viewAllBooksView)
    containerView.addSubview(viewAllSelectionsView)
    containerView.addSubview(topSeparator)
    containerView.addSubview(middleSeparator)
    containerView.addSubview(bottomSeparator)
    
    topSeparator.alignTopEdge(withView: containerView, predicate: "0")
    topSeparator.alignLeading("\(leftMargin)", trailing: "0", toView: containerView)
    viewAllBooksView.constrainTopSpace(toView: topSeparator, predicate: "0")
    viewAllBooksView.alignLeading("0", trailing: "0", toView: containerView)
    viewAllBooksView.constrainHeight("45")
    middleSeparator.constrainTopSpace(toView: viewAllBooksView, predicate: "0")
    middleSeparator.alignLeading("0", trailing: "0", toView: topSeparator)
    viewAllSelectionsView.constrainTopSpace(toView: middleSeparator, predicate: "0")
    viewAllSelectionsView.alignLeading("0", trailing: "0", toView: containerView)
    viewAllSelectionsView.constrainHeight("45")
    bottomSeparator.constrainTopSpace(toView: viewAllSelectionsView, predicate: "0")
    bottomSeparator.alignLeading("0", trailing: "0", toView: containerView)
    
    return containerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if tableView === bookwittySuggestsTableView {
      return 45
    } else {
      return SectionTitleHeaderView.minimumHeight
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView === bookwittySuggestsTableView {
      return 45
    } else {
      return BookTableViewCell.minimumHeight
    }
  }
  
  // MARK: Table View Delegate
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if tableView === bookwittySuggestsTableView {
      return 0.01 // To remove the separator after the last cell
    } else {
      return 93
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Disclosure view delegate

extension BookStoreViewController: DisclosureViewDelegate {
  func disclosureViewTapped(_ disclosureView: DisclosureView) {
    switch disclosureView {
    case viewAllCategories:
      pushCategoriesViewController()
    case viewAllBooksView:
      break
    case viewAllSelectionsView:
      break
    default:
      break
    }
  }
}
