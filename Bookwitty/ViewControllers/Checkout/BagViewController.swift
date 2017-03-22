//
//  BagViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BagViewController: ASViewController<ASDisplayNode> {
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init() {
    let bagNode = BagNode()
    super.init(node: bagNode)
    bagNode.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeNavigationItems()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Bag)
  }
  
  private func initializeNavigationItems() {
    if !UserManager.shared.isSignedIn {
      return
    }
    let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    leftNegativeSpacer.width = -10
    let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.settingsButtonTap(_:)))
    navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
  }
  
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }
}

extension BagViewController: BagNodeDelegate {
  func bagNodeShopOnline(node: BagNode) {

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Bag,
                                                 action: .GoToBagOnWebsite)
    Analytics.shared.send(event: event)

    let language = Localization.Language(rawValue: GeneralSettings.sharedInstance.preferredLanguage) ??
    Localization.Language.English
    guard let url = URL(string: "/books/\(language.rawValue)",
      relativeTo: Environment.current.baseURL) else {
        return
    }
    UIApplication.shared.openURL(url)
  }
}

//MARK: - Localizable implementation
extension BagViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.bag()
    tabBarItem.title = Strings.bag().uppercased()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
