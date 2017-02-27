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
  
  let viewModel = CategoryViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
}
