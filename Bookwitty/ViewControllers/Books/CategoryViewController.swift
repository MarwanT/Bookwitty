//
//  CategoryViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  
  let banner = BannerView()
  let featuredContentCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
  let bookwittySuggestsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let selectionTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let viewAllBooksView = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewSubcategories = UIView.loadFromView(DisclosureView.self, owner: nil)
  let refreshController = UIRefreshControl()
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  fileprivate let sectionSpacing = ThemeManager.shared.currentTheme.sectionSpacing()
  
  let viewModel = CategoryViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    initializePullToRefresh()
    initializeSubviews()
    
    refreshViewController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    /*
     When the refresh controller is still refreshing, and we navigate away and
     back to this view controller, the activity indicator stops animating.
     The is a turn around to re animate it if needed
     */
    if refreshController.isRefreshing == true {
      let offset = scrollView.contentOffset
      refreshController.endRefreshing()
      refreshController.beginRefreshing()
      scrollView.contentOffset = offset
    }
  }
  
  private func initializeSubviews() {
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
    
    // View All Books
    viewAllBooksView.configuration.style = .highlighted
    viewAllBooksView.delegate = self
    viewAllBooksView.label.text = Strings.view_all_books()
    
    // View Subcategories
    viewSubcategories.configuration.style = .highlighted
    viewSubcategories.delegate = self
    viewSubcategories.label.text = Strings.view_subcategories()
  }
  
  private func initializePullToRefresh() {
    scrollView.alwaysBounceVertical = true
    scrollView.addSubview(refreshController)
    refreshController.addTarget(self, action: #selector(refreshViewController), for: .valueChanged)
  }
  
  // MARK: Actions
  func refreshViewController() {
    refreshController.beginRefreshing()
    viewModel.loadData { (success, error) in
      self.refreshController.endRefreshing()
      // Clear All Subviews in stack view
      self.stackView.subviews.forEach({ $0.removeFromSuperview() })
      self.loadUserInterface()
      // TODO: If there is nothing to be displayed display no data view
    }
  }
  
  
  // MARK: Subviews Builders
  private func loadUserInterface() {
    loadBannerSection()
    loadFeaturedContentSection()
    loadBookwittySuggest()
    loadSelectionSection()
    loadSubcategoriesSection()
  }
  
  private func loadBannerSection() {
    let canDisplayBanner = banner.superview == nil
    if viewModel.hasBanner && canDisplayBanner {
      banner.imageURL = viewModel.bannerImageURL
      banner.title = viewModel.bannerTitle
      banner.subtitle = viewModel.bannerSubtitle
      self.stackView.addArrangedSubview(self.banner)
    }
  }
  
  private func loadFeaturedContentSection() {
    let canDisplayFeaturedContent = featuredContentCollectionView.superview == nil
    if viewModel.hasFeaturedContent && canDisplayFeaturedContent {
      stackView.addArrangedSubview(featuredContentCollectionView)
      addSeparator(leftMargin)
    }
  }
  
  private func loadBookwittySuggest() {
    let canDisplayBookwittySuggest = bookwittySuggestsTableView.superview == nil
    if viewModel.hasBookwittySuggests && canDisplayBookwittySuggest {
      addSpacing(space: 10)
      stackView.addArrangedSubview(bookwittySuggestsTableView)
      bookwittySuggestsTableView.alignLeading("0", trailing: "0", toView: stackView)
      // Add the table view height constraint
      bookwittySuggestsTableView.layoutIfNeeded()
      bookwittySuggestsTableView.constrainHeight("\(bookwittySuggestsTableView.contentSize.height)")
      addSeparator()
    }
  }
  
  private func loadSelectionSection() {
    let canDisplaySelection = selectionTableView.superview == nil
    if viewModel.hasSelectionSection && canDisplaySelection {
      addSpacing(space: sectionSpacing)
      stackView.addArrangedSubview(selectionTableView)
      selectionTableView.alignLeading("0", trailing: "0", toView: stackView)
      // Add the table view height constraint
      selectionTableView.layoutIfNeeded()
      selectionTableView.constrainHeight("\(selectionTableView.contentSize.height)")
    }
  }
  
  private func loadSubcategoriesSection() {
    let canDisplayViewAllSubcategories = viewSubcategories.superview == nil
    if viewModel.hasSubcategories && canDisplayViewAllSubcategories {
      addSeparator(leftMargin)
      viewSubcategories.constrainHeight("45")
      stackView.addArrangedSubview(viewSubcategories)
      viewSubcategories.alignLeading("0", trailing: "0", toView: stackView)
      addSeparator()
    }
  }
  
  
  // MARK: Alerts
  private func showAlertWith(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.ok(), style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  
  // MARK: Helpers
  fileprivate func separatorViewInstance() -> UIView {
    let separatorView = UIView(frame: CGRect.zero)
    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separatorView.constrainHeight("1")
    return separatorView
  }
  
  private func addSeparator(_ leftMargin: CGFloat = 0) {
    let separatorView = separatorViewInstance()
    let containerView = UIView(frame: CGRect.zero)
    containerView.addSubview(separatorView)
    separatorView.alignLeadingEdge(withView: containerView, predicate: "\(leftMargin)")
    separatorView.alignTrailingEdge(withView: containerView, predicate: "0")
    separatorView.alignTop("0", bottom: "0", toView: containerView)
    stackView.addArrangedSubview(containerView)
    containerView.alignLeading("0", trailing: "0", toView: stackView)
  }
  
  private func addSpacing(space: CGFloat) {
    guard space > 0 else {
      return
    }
    
    let spacer = UIView(frame: CGRect.zero)
    spacer.backgroundColor = UIColor.clear
    spacer.constrainHeight("\(space)")
    stackView.addArrangedSubview(spacer)
  }
  
  func pushSubcategoriesList() {
    guard let subcategories = viewModel.subcategories else {
      return
    }
    let categoriesTableViewController = Storyboard.Books.instantiate(CategoriesTableViewController.self)
    categoriesTableViewController.viewModel.categories = subcategories
    navigationController?.pushViewController(categoriesTableViewController, animated: true)
  }
  
  func pushBooksTableView(with books: [Book]? = nil, loadingMode: DataLoadingMode? = nil) {
    let booksTableViewController = Storyboard.Books.instantiate(BooksTableViewController.self)
    booksTableViewController.initialize(with: books, loadingMode: loadingMode)
    navigationController?.pushViewController(booksTableViewController, animated: true)
  }
  
  fileprivate func pushBookDetailsViewController(with book: Book) {
    let bookDetailsViewController = BookDetailsViewController(with: book)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }
}


// MARK: - Featured Content Collection Delegates

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO: Handle featured content selection
  }
}


// MARK: - Table Views Delegates & Data Source

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
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
      tableHeaderLabel.text = Strings.bookwitty_suggests()
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
      headerView.label.text = Strings.our_selection_for_you()
      let headerConfiguration = SectionTitleHeaderView.Configuration(
        verticalBarColor: ThemeManager.shared.currentTheme.colorNumber6(),
        horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber5())
      headerView.configuration = headerConfiguration
      return headerView
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard tableView === selectionTableView else {
      return nil
    }
    
    let topSeparator = separatorViewInstance()
    
    let containerView = UIView(frame: CGRect.zero)
    containerView.addSubview(viewAllBooksView)
    containerView.addSubview(topSeparator)
    
    topSeparator.alignTopEdge(withView: containerView, predicate: "0")
    topSeparator.alignLeading("\(leftMargin)", trailing: "0", toView: containerView)
    viewAllBooksView.constrainTopSpace(toView: topSeparator, predicate: "0")
    viewAllBooksView.alignLeading("0", trailing: "0", toView: containerView)
    viewAllBooksView.constrainHeight("45")
    
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
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if tableView === bookwittySuggestsTableView {
      return 0.01 // To remove the separator after the last cell
    } else {
      return 46
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if tableView === bookwittySuggestsTableView {
      
    } else {
      guard let book = viewModel.book(for: indexPath) else {
        return
      }
      pushBookDetailsViewController(with: book)
    }
  }
}

// MARK: - Disclosure view delegate

extension CategoryViewController: DisclosureViewDelegate {
  func disclosureViewTapped(_ disclosureView: DisclosureView) {
    switch disclosureView {
    case viewAllBooksView:
      pushBooksTableView(with: viewModel.books, loadingMode: viewModel.booksLoadingMode)
    case viewSubcategories:
      pushSubcategoriesList()
    default:
      break
    }
  }
}