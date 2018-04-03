//
//  CallToActionViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2018/04/03.
//  Copyright © 2018 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CallToActionViewController: ASViewController<ASDisplayNode> {

  fileprivate let controllerNode = ASDisplayNode()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(node: controllerNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
}
