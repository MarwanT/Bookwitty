//
//  ContentEditorViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ContentEditorViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    loadNavigationBarButtons()
  }
  
  private func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    
    let close = UIBarButtonItem(title: Strings.close(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: nil)
    
    let drafts = UIBarButtonItem(title: Strings.drafts(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: nil)
    
    let undo = UIBarButtonItem(image: #imageLiteral(resourceName: "undo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    
    let redo = UIBarButtonItem(image: #imageLiteral(resourceName: "redo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    let plus = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    
    let next = UIBarButtonItem(title: Strings.next(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: nil)
   
    let leftBarButtonItems = [close,drafts,undo]
    let rightBarButtonItems = [next,plus,redo]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
}
