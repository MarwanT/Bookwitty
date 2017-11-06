//
//  BookStoreViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout
import Spine
import AsyncDisplayKit

class BookStoreViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var scrollView: UIScrollView!
  
  let introductoryBanner = IntroductoryBanner(mode: IntroductoryBanner.Mode.shop)
  let banner = BannerView()
  let featuredContentCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
  let bookwittySuggestsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let selectionTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let viewAllCategories = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllBooksView = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllSelectionsView = UIView.loadFromView(DisclosureView.self, owner: nil)
  
  let refreshController = UIRefreshControl()
  
  let viewModel = BookStoreViewModel()
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  fileprivate let sectionSpacing = ThemeManager.shared.currentTheme.sectionSpacing()

  fileprivate var introductoryBannerHeightConstraint: NSLayoutConstraint?

  override func awakeFromNib() {
    super.awakeFromNib()

    addObservers()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.dataLoaded = viewModelLoadedDataBlock()

    initializeNavigationItems()
    initializePullToRefresh()
    initializeSubviews()
    refreshViewController()

    applyLocalization()
    navigationItem.backBarButtonItem = UIBarButtonItem.back
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
    } else {
      refreshController.endRefreshing()
    }

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookStorefront)
  }

  private func addObservers() {
    observeLanguageChanges()

    NotificationCenter.default.addObserver(self, selector:
      #selector(self.authenticationStatusChanged(_:)), name: AppNotification.authenticationStatusChanged, object: nil)
  }

  @objc private func authenticationStatusChanged(_: Notification) {
    initializeNavigationItems()
  }

  private func initializeNavigationItems() {
    if !UserManager.shared.isSignedIn {
      navigationItem.leftBarButtonItems = nil
    } else {
      let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
        UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
      leftNegativeSpacer.width = -10
      let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
        UIBarButtonItemStyle.plain, target: self, action:
        #selector(self.settingsButtonTap(_:)))
      navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
    }
    
    let rightNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    rightNegativeSpacer.width = -10
    let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.searchButtonTap(_:)))
    navigationItem.rightBarButtonItems = [rightNegativeSpacer, searchBarButton]
  }
  
  private func initializePullToRefresh() {
    scrollView.alwaysBounceVertical = true
    scrollView.addSubview(refreshController)
    refreshController.addTarget(self, action: #selector(refreshViewController), for: .valueChanged)
  }
  
  private func initializeSubviews() {
    // Introductory Banner
    introductoryBanner.delegate = self
    
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
    selectionTableView.sectionHeaderHeight = UITableViewAutomaticDimension
    selectionTableView.estimatedSectionHeaderHeight = SectionTitleHeaderView.minimumHeight
    selectionTableView.isScrollEnabled = false
    
    // View All Books
    viewAllBooksView.configuration.style = .highlighted
    viewAllBooksView.delegate = self
    viewAllBooksView.constrainHeight("45")
    
    // View All Selections
    viewAllSelectionsView.configuration.style = .highlighted
    viewAllSelectionsView.delegate = self
    viewAllSelectionsView.constrainHeight("45")
  }
  
  private func viewModelLoadedDataBlock() -> (_ finished: Bool) -> Void {
    return { (finished: Bool) -> Void in
      self.loadUserInterface()
    }
  }
  
  func refreshViewController() {
    viewModel.clearData()
    clearSubviews()

    refreshController.beginRefreshing()
    viewModel.loadData { (success, error) in
      self.refreshController.endRefreshing()
      guard success else {
        // TODO: Display the bookwitty error view
        self.showAlertWith(title: Strings.error_loading_data(), message: Strings.couldnt_load_your_data())
        return
      }
      // Clear All Subviews in stack view
      self.stackView.subviews.forEach({ $0.removeFromSuperview() })
      self.loadUserInterface()
    }
  }
  
  func clearSubviews() {
    let subviews = stackView.subviews
    for view in subviews {
      view.removeFromSuperview()
    }
  }
  
  fileprivate func removeInformativeBanner() {
    introductoryBanner.view.removeFromSuperview()
  }
  
  private func loadUserInterface() {
    loadIntroductorySection()
    loadBannerSection()
    loadFeaturedContentSection()
    loadViewAllCategories()
    loadBookwittySuggest()
    loadSelectionSection()
    loadViewAllSelections()
  }
  
  func loadIntroductorySection() {
    let canDisplayIntroductoryBanner = introductoryBanner.view.superview == nil
    if canDisplayIntroductoryBanner && viewModel.shouldDisplayIntroductoryBanner {
      stackView.addArrangedSubview(self.introductoryBanner.view)
      introductoryBanner.view.alignLeading("0", trailing: "0", toView: self.stackView)
      let calculatedSize = introductoryBanner.calculateLayoutThatFits(ASSizeRange(min: CGSize.zero, max: self.view.frame.size)).frame.size

      if introductoryBannerHeightConstraint == nil {
        introductoryBannerHeightConstraint = introductoryBanner.view.heightAnchor.constraint(equalToConstant: calculatedSize.height)
        introductoryBannerHeightConstraint?.isActive = true
      }

      introductoryBannerHeightConstraint?.constant = calculatedSize.height
      introductoryBanner.view.layoutIfNeeded()
    }
  }
  
  func loadBannerSection() {
    let canDisplayBanner = banner.superview == nil
    if viewModel.hasBanner && canDisplayBanner {
      banner.imageURL = viewModel.bannerImageURL
      banner.title = viewModel.bannerTitle
      banner.subtitle = viewModel.bannerSubtitle
      stackView.addArrangedSubview(self.banner)
      banner.alignLeading("0", trailing: "0", toView: self.stackView)
    }
  }
  
  func loadFeaturedContentSection() {
    let canDisplayFeaturedContent = featuredContentCollectionView.superview == nil
    if viewModel.hasFeaturedContent && canDisplayFeaturedContent {
      featuredContentCollectionView.reloadData()
      stackView.addArrangedSubview(featuredContentCollectionView)
      addSeparator(leftMargin)
    }
  }
  
  func loadViewAllCategories() {
    let canDisplayCategories = viewAllCategories.superview == nil
    if viewModel.hasCategories && canDisplayCategories {
      stackView.addArrangedSubview(viewAllCategories)
      viewAllCategories.alignLeading("0", trailing: "0", toView: stackView)
      addSeparator()
    }
  }
  
  func loadBookwittySuggest() {
    let canDisplayBookwittySuggest = bookwittySuggestsTableView.superview == nil
    if viewModel.hasBookwittySuggests && canDisplayBookwittySuggest {
      bookwittySuggestsTableView.reloadData()
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
      selectionTableView.reloadData()
      addSeparator()
      addSpacing(space: sectionSpacing)
      stackView.addArrangedSubview(selectionTableView)
      selectionTableView.alignLeading("0", trailing: "0", toView: stackView)
      // Add the table view height constraint
      selectionTableView.layoutIfNeeded()
      selectionTableView.constrainHeight("\(selectionTableView.contentSize.height)")
    }
  }
  
  func loadViewAllSelections() {
    let canDisplayViewAllSelections = viewAllSelectionsView.superview == nil
    if viewModel.hasSelectionSection && canDisplayViewAllSelections {
      addSeparator(leftMargin)
      stackView.addArrangedSubview(viewAllSelectionsView)
      viewAllSelectionsView.alignLeading("0", trailing: "0", toView: stackView)
      addSeparator()
    }
  }
  
  func addSeparator(_ leftMargin: CGFloat = 0) {
    let separatorView = separatorViewInstance()
    let containerView = UIView(frame: CGRect.zero)
    containerView.addSubview(separatorView)
    separatorView.alignLeadingEdge(withView: containerView, predicate: "\(leftMargin)")
    separatorView.alignTrailingEdge(withView: containerView, predicate: "0")
    separatorView.alignTop("0", bottom: "0", toView: containerView)
    stackView.addArrangedSubview(containerView)
    containerView.alignLeading("0", trailing: "0", toView: stackView)
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
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookStorefront,
                                                 action: .ViewAllCategories)
    Analytics.shared.send(event: event)

    let categoriesViewController = Storyboard.Books.instantiate(CategoriesTableViewController.self)
    categoriesViewController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(categoriesViewController, animated: true)
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
    bookDetailsViewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }
  
  // MARK: Helpers
  
  func pushBooksTableView(with books: [Book]? = nil, loadingMode: BooksTableViewController.DataLoadingMode? = nil) {
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookStorefront,
                                                 action: .ViewAllBooks)
    Analytics.shared.send(event: event)

    let booksTableViewController = Storyboard.Books.instantiate(BooksTableViewController.self)
    booksTableViewController.initialize(with: books, loadingMode: loadingMode)
    booksTableViewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(booksTableViewController, animated: true)
  }

  fileprivate func pushReadingListsViewController(with readingLists: [ReadingList]) {
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookStorefront,
                                                 action: .ViewAllReadingLists)
    Analytics.shared.send(event: event)

    let readingListsViewController = ReadingListsViewController()
    readingListsViewController.initialize(with: readingLists)
    navigationController?.pushViewController(readingListsViewController, animated: true)
  }
}

// MARK: - Action
extension BookStoreViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }

  func searchButtonTap(_ sender: UIBarButtonItem) {
    let searchVC = SearchViewController()
    searchVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(searchVC, animated: true)
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

// MARK: - Featured Content Collection View Delegate
extension BookStoreViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let modelResource = viewModel.featuredResource(for: indexPath) else {
      return
    }
    actionForCard(resource: modelResource)
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
    
    return containerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if tableView === bookwittySuggestsTableView {
      return 45
    } else {
      return UITableViewAutomaticDimension
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
      return 46
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if tableView === bookwittySuggestsTableView {
      guard let modelResource = viewModel.suggestedReadingList(for: indexPath) else {
        return
      }
      actionForCard(resource: modelResource)
    } else {
      guard let book = viewModel.book(for: indexPath) else {
        return
      }
      pushBookDetailsViewController(with: book)
    }
  }
}

// MARK: - Disclosure view delegate
extension BookStoreViewController: DisclosureViewDelegate {
  func disclosureViewTapped(_ disclosureView: DisclosureView) {
    switch disclosureView {
    case viewAllCategories:
      pushCategoriesViewController()
    case viewAllBooksView:
      pushBooksTableView(with: viewModel.books, loadingMode: viewModel.booksLoadingMode)
    case viewAllSelectionsView:
      pushReadingListsViewController(with: viewModel.selections)
    default:
      break
    }
  }
}

// MARK: - Actions For Selected Resource
extension BookStoreViewController {
  func actionForCard(resource: ModelResource?) {
    guard let resource = resource,
      !DataManager.shared.isReported(resource) else {
      return
    }

    let registeredType = resource.registeredResourceType
    
    switch registeredType {
    case Image.resourceType:
      actionForImageResourceType(resource: resource)
    case Author.resourceType:
      actionForAuthorResourceType(resource: resource)
    case ReadingList.resourceType:
      actionForReadingListResourceType(resource: resource)
    case Topic.resourceType:
      actionForTopicResourceType(resource: resource)
    case Text.resourceType:
      actionForTextResourceType(resource: resource)
    case Quote.resourceType:
      actionForQuoteResourceType(resource: resource)
    case Video.resourceType:
      actionForVideoResourceType(resource: resource)
    case Audio.resourceType:
      actionForAudioResourceType(resource: resource)
    case Link.resourceType:
      actionForLinkResourceType(resource: resource)
    case Book.resourceType:
      actionForBookResourceType(resource: resource)
    case PenName.resourceType:
      if let penName = resource as? PenName {
        pushProfileViewController(penName: penName)

        //MARK: [Analytics] Event
        let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                     action: .GoToDetails,
                                                     name: penName.name ?? "")
        Analytics.shared.send(event: event)
      }
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }
  
  func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    nodeVc.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }
  
  func pushGenericViewControllerCard(resource: Resource, title: String? = nil) {
    guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
      return
    }
    
    cardNode.baseViewModel?.resource = resource as? ModelCommonProperties
    let genericVC = CardDetailsViewController(node: cardNode, title: title, resource: resource)
    genericVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(genericVC, animated: true)
  }
  
  fileprivate func actionForImageResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Image)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Image,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }
  
  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    guard resource is Author else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Author)?.name ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Author,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
    topicViewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(topicViewController, animated: true)
  }
  
  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? ReadingList)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .ReadingList,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
  }
  
  fileprivate func actionForTopicResourceType(resource: ModelResource) {
    guard resource is Topic else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Topic)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Topic,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
    topicViewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(topicViewController, animated: true)
  }
  
  fileprivate func actionForTextResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Text)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Text,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
  }
  
  fileprivate func actionForQuoteResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Quote)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Quote,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }
  
  fileprivate func actionForVideoResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Video)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Video,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }
  
  fileprivate func actionForAudioResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Audio)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Audio,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }
  
  fileprivate func actionForLinkResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Link)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Link,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }
  
  fileprivate func actionForBookResourceType(resource: ModelResource) {
    guard resource is Book else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Book)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .TopicBook,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
    topicViewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(topicViewController, animated: true)
  }
}

//MARK: - Localizable implementation
extension BookStoreViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.books()
    tabBarItem.title = Strings.books().uppercased()
    viewAllCategories.label.text = Strings.view_all_categories()
    viewAllBooksView.label.text = Strings.view_all_books()
    viewAllSelectionsView.label.text = Strings.view_all_selections()
    bookwittySuggestsTableView.reloadData()
    selectionTableView.reloadData()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()

    guard isViewLoaded else {
      return
    }

    //Reload the Data upon language change
    refreshViewController()
  }
}

// MARK: - Introductory Node Delegate
extension BookStoreViewController: IntroductoryBannerDelegate {
  func introductoryBannerDidTapDismissButton(_ introductoryBanner: IntroductoryBanner) {
    viewModel.shouldDisplayIntroductoryBanner = false
    removeInformativeBanner()
  }
}
