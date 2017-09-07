//
//  ProductFormatsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol ProductFormatsViewControllerDelegate {
  func productFormats(_ viewController: ProductFormatsViewController, selected editionId: String, didFinishLoading completion: ((_ success: Bool) -> Void)?)
}

class ProductFormatsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  fileprivate var viewModel = ProductFormatsViewModel()
  
  var delegate: ProductFormatsViewControllerDelegate?
  
  var shouldShowLoader: Bool = false {
    didSet {
      switch shouldShowLoader {
      case true:
        showActivityIndicator()
      case false:
        hideActivityIndicator()
      }
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ProductFormats)
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.register(PreferredFormatTableViewCell.nib, forCellReuseIdentifier: PreferredFormatTableViewCell.reuseIdentifier)
    tableView.register(UniColorSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: UniColorSectionHeaderView.reuseIdentifier)
    tableView.register(CollapsableTableViewSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: CollapsableTableViewSectionHeaderView.reuseIdentifier)
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    
    tableView.separatorInset.left = ThemeManager.shared.currentTheme.generalExternalMargin()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    tableView.layoutMargins = UIEdgeInsets.zero
    
    // Configurae activity indicator
    activityIndicator.activityIndicatorViewStyle = .white
    activityIndicator.color = UIColor.bwRuby
    activityIndicator.hidesWhenStopped = true
    activityIndicator.backgroundColor = UIColor.clear
    activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
    
    reloadData()
  }
  
  fileprivate func reloadData() {
    shouldShowLoader = true
    viewModel.loadData { (success, error) in
      self.shouldShowLoader = false
      self.refreshTableView()
    }
  }
  
  func initialize(with book: Book) {
    self.viewModel.initialize(with: book)
  }
  
  fileprivate func refreshTableView() {
    let sections = [
      Section.preferredFormats,
      Section.availableFormats,
    ]
    
    let mutableIndexSet = NSMutableIndexSet()
    sections.forEach({ mutableIndexSet.add($0.rawValue) })
    tableView.reloadSections(mutableIndexSet as IndexSet, with: UITableViewRowAnimation.none)
    tableView.reloadSections(IndexSet(integer: Section.availableFormats.rawValue), with: .none)
  }
  
  func showActivityIndicator() {
    tableView.tableFooterView = activityIndicator
    activityIndicator.startAnimating()
  }
  
  func hideActivityIndicator() {
    activityIndicator.stopAnimating()
    tableView.tableFooterView = UIView(frame: CGRect.zero)
  }
  
  fileprivate func didSelectEdition(id: String) {
    delegate?.productFormats(self, selected: id, didFinishLoading: {
      (success) in
      if success {
        self.navigationController?.popToViewController(self, animated: false)
        self.navigationController?.popViewController(animated: true)
      } else {
        self.showAlertWith(
          title: Strings.couldnt_load_selected_edition_title(),
          message: Strings.couldnt_load_selected_edition_message())
      }
    })
  }

  fileprivate func pushFormatEditionsViewController(productId: String, productForm: ProductForm) {
    let viewController = Storyboard.Books.instantiate(FormatEditionsViewController.self)
    viewController.initialize(initialProductIdentifier: productId, productForm: productForm)
    viewController.delegate = self
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: Declare Section
extension ProductFormatsViewController {
  enum Section: Int {
    case preferredFormats = 0
    case availableFormats
    
    static var numberOfSections: Int {
      return 2
    }
  }
}

// MARK: Table View Delegates
extension ProductFormatsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: indexPath.section) else {
      return UITableViewCell()
    }
    
    switch section {
    case .preferredFormats:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: PreferredFormatTableViewCell.reuseIdentifier, for: indexPath) as? PreferredFormatTableViewCell else {
        return UITableViewCell()
      }
      return cell
    case .availableFormats:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureTableViewCell.identifier, for: indexPath) as? DisclosureTableViewCell else {
        return UITableViewCell()
      }

      cell.detailsLabel.font = FontDynamicType.caption1.font
      cell.detailsLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
      return cell
    }
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else {
      return
    }

    switch section {
    case .preferredFormats:
      guard let currentCell = cell as? PreferredFormatTableViewCell, let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.PreferredFormatValues else {
        return
      }

      currentCell.primaryLabel.text = values.form.value
      currentCell.secondaryLabel.text = values.price?.formattedValue
      currentCell.isSelected = values.isSelected
    case .availableFormats:
      guard let currentCell = cell as? DisclosureTableViewCell, let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.AvailableFormatValues else {
        return
      }

      currentCell.label.text = values.form.value
      currentCell.detailsLabel.text = "(" + String(describing: values.numberOfEditions) + ")"
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else {
      return
    }
    
    switch section {
    case .preferredFormats:

      guard let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.PreferredFormatValues else {
        return
      }

      viewModel.selectPreferredFormat(indexPath)

      tableView.reloadSections(IndexSet(integer: section.rawValue), with: UITableViewRowAnimation.none)

      didSelectEdition(id: values.id)

      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(
        category: .BookProduct,
        action: .ChoosePreferredFormat,
        name: "\(viewModel.productTitle ?? "") - \(values.form.value)" )
      Analytics.shared.send(event: event)

    case .availableFormats:
      guard let values = viewModel.values(for: indexPath) as? ProductFormatsViewModel.AvailableFormatValues, let productId = viewModel.productId else {
        tableView.deselectRow(at: indexPath, animated: true)
        return
      }
      pushFormatEditionsViewController(productId: productId, productForm: values.form)
      tableView.deselectRow(at: indexPath, animated: true)
      
      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(
        category: .BookProduct,
        action: .GoToEditions,
        name: "\(viewModel.productTitle ?? "") - \(values.form.value)" )
      Analytics.shared.send(event: event)
    }
  }
  
  
  // Headers $ Footers
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let values = viewModel.sectionValues(for: section), let section = Section(rawValue: section) else {
      return nil
    }
    
    switch section {
    case .preferredFormats:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UniColorSectionHeaderView.reuseIdentifier) else {
        return nil
      }
      headerView.textLabel?.text = values as? String
      let color = UIColor.bwOrangeLight

      /** Discussion
       * Setting the background color on UITableViewHeaderFooterView has been deprecated, BUT contentView.backgroundColor was not working on the IPOD or IPHONE-5/s
       * so we kept both until 'contentView.backgroundColor' work 100% on all supported devices
       */
      headerView.contentView.backgroundColor = color
      if let imagebg = color.image(size: CGSize(width: headerView.frame.width, height: headerView.frame.height)) {
        headerView.backgroundView = UIImageView(image: imagebg)
      }

      return headerView
    case .availableFormats:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CollapsableTableViewSectionHeaderView.reuseIdentifier) as? CollapsableTableViewSectionHeaderView, let values = values as? ProductFormatsViewModel.AvailableFormatHeaderValues else {
        return nil
      }
      headerView.configuration.titleLabelTextColor = ThemeManager.shared.currentTheme.defaultECommerceColor()
      headerView.configuration.contentLayoutMargin.right = 2
      headerView.mode = values.mode
      headerView.titleLabel.text = values.title
      headerView.subTitleLabel.text = nil
      headerView.section = section.rawValue
      headerView.delegate = self
      return headerView
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard viewModel.sectionValues(for: section) != nil, let section = Section(rawValue: section) else {
      return 0
    }
    
    switch section {
    case .preferredFormats:
      return 50
    case .availableFormats:
      return 50.0
    default:
      return 0.0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01 // To remove the separator after the last cell
  }
}

// MARK: format editions view controller delegate implementation
extension ProductFormatsViewController: FormatEditionsViewControllerDelegate {
  func formatEditions(_ viewController: FormatEditionsViewController, selected editionId: String) {
    didSelectEdition(id: editionId)
  }
}

// MARK: Collapsable table view section header view delegate implementation
extension ProductFormatsViewController: CollapsableTableViewSectionHeaderViewDelegate {
  func sectionHeader(view: CollapsableTableViewSectionHeaderView, request mode: CollapsableTableViewSectionHeaderView.Mode) {
    guard let rawSection = view.section else {
      return
    }
    
    viewModel.toggleSection()
    tableView.reloadSections(IndexSet(integer: rawSection), with: .none)
  }
}
