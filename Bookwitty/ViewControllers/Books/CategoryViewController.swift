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
  let viewAllSelectionsView = UIView.loadFromView(DisclosureView.self, owner: nil)
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  
  let viewModel = CategoryViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    initializeSubviews()
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
  }
  
  
  // MARK: Helpers
  fileprivate func separatorViewInstance() -> UIView {
    let separatorView = UIView(frame: CGRect.zero)
    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separatorView.constrainHeight("1")
    return separatorView
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
    return viewModel.bookwittySuggestsNumberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.bookwittySuggestsNumberOfItems
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier) ?? UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? DisclosureTableViewCell else {
      return
    }
    let value = viewModel.bookwittySuggestsValues(for: indexPath)
    cell.label.text = value
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 45
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
  
  // MARK: Table View Delegate
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
