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
  
  let bookwittySuggestsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let selectionTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
  let viewAllCategories = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllBooksView = UIView.loadFromView(DisclosureView.self, owner: nil)
  let viewAllSelectionsView = UIView.loadFromView(DisclosureView.self, owner: nil)
  
  let viewModel = BookStoreViewModel()
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  fileprivate let sectionSpacing = ThemeManager.shared.currentTheme.sectionSpacing()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let didAddBanner = loadBannerSection()
    let didAddFeaturedSection = loadFeaturedContentSection()
    addSeparator(leftMargin)
    let didAddViewAllCategoriesSection = loadViewAllCategories()
    addSeparator()
    addSpacing(space: 10)
    let didLoadBookwittySuggests = loadBookwittySuggest()
    addSeparator()
    addSpacing(space: sectionSpacing)
    let didLoadSelectionSection = loadSelectionSection()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Add the table view height constraint constraint
    bookwittySuggestsTableView.layoutIfNeeded()
    bookwittySuggestsTableView.constrainHeight("\(bookwittySuggestsTableView.contentSize.height)")
    
    selectionTableView.layoutIfNeeded()
    selectionTableView.constrainHeight("\(selectionTableView.contentSize.height)")
  }
  
  func loadBannerSection() -> Bool {
    let banner = Banner()
    banner.image = #imageLiteral(resourceName: "Illustrtion")
    banner.title = "Bookwitty's Finest"
    banner.subtitle = "The perfect list for everyone on your list"
    stackView.addArrangedSubview(banner)
    return true
  }
  
  func loadFeaturedContentSection() -> Bool {
    let itemSize = FeaturedContentCollectionViewCell.defaultSize
    let interItemSpacing: CGFloat = 10
    let contentInset = UIEdgeInsets(
      top: 15, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 10, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
    flowLayout.itemSize = itemSize
    flowLayout.minimumInteritemSpacing = interItemSpacing
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    collectionView.register(FeaturedContentCollectionViewCell.nib, forCellWithReuseIdentifier: FeaturedContentCollectionViewCell.reuseIdentifier)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clear
    collectionView.contentInset = contentInset
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.constrainHeight("\(itemSize.height + contentInset.top + contentInset.bottom)")
    collectionView.constrainWidth("\(self.view.frame.width)")
    
    stackView.addArrangedSubview(collectionView)
    
    return true
  }
  
  func loadViewAllCategories() -> Bool {
    viewAllCategories.configuration.style = .highlighted
    viewAllCategories.delegate = self
    viewAllCategories.label.text = viewModel.viewAllCategoriesLabelText
    
    viewAllCategories.constrainHeight("45")
    stackView.addArrangedSubview(viewAllCategories)
    viewAllCategories.alignLeadingEdge(withView: stackView, predicate: "0")
    viewAllCategories.alignTrailingEdge(withView: stackView, predicate: "0")
    return true
  }
  
  func loadBookwittySuggest() -> Bool {
    bookwittySuggestsTableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bookwittySuggestsTableView.separatorInset = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    bookwittySuggestsTableView.dataSource = self
    bookwittySuggestsTableView.delegate = self
    bookwittySuggestsTableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    stackView.addArrangedSubview(bookwittySuggestsTableView)
    bookwittySuggestsTableView.alignLeading("0", trailing: "0", toView: stackView)
    return true
  }
  
  func loadSelectionSection() -> Bool {
    selectionTableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    selectionTableView.separatorInset = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    selectionTableView.dataSource = self
    selectionTableView.delegate = self
    selectionTableView.register(SectionTitleHeaderView.nib, forHeaderFooterViewReuseIdentifier: SectionTitleHeaderView.reuseIdentifier)
    selectionTableView.register(BookTableViewCell.nib, forCellReuseIdentifier: BookTableViewCell.reuseIdentifier)
    stackView.addArrangedSubview(selectionTableView)
    selectionTableView.alignLeading("0", trailing: "0", toView: stackView)
    return true
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
    
    let data = viewModel.dataForFeaturedContent(indexPath: indexPath)
    cell.title = data.title
    cell.image = data.image
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
      guard let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier) as? DisclosureTableViewCell else {
        return UITableViewCell()
      }
      
      let data = viewModel.dataForBookwittySuggests(indexPath)
      cell.label.text = data
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.reuseIdentifier) as? BookTableViewCell else {
        return UITableViewCell()
      }
      
      let values = viewModel.selectionValues(for: indexPath)
      cell.productImage = values.image
      cell.bookTitle = values.bookTitle
      cell.authorName = values.authorName
      cell.productType = values.productType
      cell.price = values.price
      return cell
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
        return UIView()
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
      break
    case viewAllBooksView:
      break
    case viewAllSelectionsView:
      break
    default:
      break
    }
  }
}
