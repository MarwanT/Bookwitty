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
    title = Strings.bag()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension BagViewController: BagNodeDelegate {
  func bagNodeShopOnline(node: BagNode) {
    UIApplication.shared.openURL(Environment.current.baseURL)
  }
}
