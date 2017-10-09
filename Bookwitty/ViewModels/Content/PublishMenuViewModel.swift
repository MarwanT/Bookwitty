//
//  PublishMenuViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PublishMenuViewModel {
  var tags: [String] = []
  var links: [String] = []
  
  var penName: PenName? = UserManager.shared.defaultPenName
  
  private func valuesForPenName() -> (profileImage: String?, name:String?) {
    return (self.penName?.avatarUrl, self.penName?.name)
  }
  
  private func valuesForLink(at indexPath: IndexPath) -> (title: String?, image:UIImage?) {
    switch indexPath.row {
    case 0:
      // Add Tags
      let item = PublishMenuViewController.Item.addTags
      return (item.localizedString, item.image)
    case 1:
      //Link Topics
      let item = PublishMenuViewController.Item.linkTopics
      return (item.localizedString, item.image)
    default:
      return (nil, nil)
    }
  }
  private func valuesForPreview(at indexPath: IndexPath) -> (title: String?, image:UIImage?) {
    let item = PublishMenuViewController.Item.postPreview
    return (item.localizedString, item.image)
  }
  private func valuesForPublish(at indexPath: IndexPath) -> (title: String?, image:UIImage?) {
    switch indexPath.row {
    case 0:
      //Publish
      let item = PublishMenuViewController.Item.publishYourPost
      return (item.localizedString, item.image)
    case 1:
      //Draft
      let item = PublishMenuViewController.Item.saveAsDraft
      return (item.localizedString, item.image)
    case 2:
      //Cancel
      let item = PublishMenuViewController.Item.goBack
      return (item.localizedString, item.image)
    default:
      return (nil, nil)
    }
  }
  //MARK: - TableView functions
  func numberOfSections() -> Int {
    return PublishMenuViewController.Section.numberOfSections
  }
  
  func numberOfRows(in section:Int) -> Int {
    guard let section = PublishMenuViewController.Section(rawValue: section)  else {
      return 0
    }
    
    switch section {
    case .penName:
      let penNames =  UserManager.shared.signedInUser.penNames ?? []
      return penNames.count > 1 ? 1 : 0
    case .link:
      return 2
    case .preview:
      return 1
    case .publish:
      return 3
    }
  }
  
  func values(forRowAt indexPath: IndexPath) -> (label: (title: String?, image:UIImage?) , values:(name:String?, image:String?, count: Int?)?) {
    var title: String? = nil
    var image: UIImage? = nil
    var name: String? = nil
    var profileImage: String? = nil
    let count: Int? = UserManager.shared.penNames?.count
    
    switch indexPath.section {
    case PublishMenuViewController.Section.penName.rawValue:
      title = PublishMenuViewController.Item.penName.localizedString
      image = PublishMenuViewController.Item.penName.image
      (profileImage, name) = valuesForPenName()
    case PublishMenuViewController.Section.link.rawValue:
      (title, image) = self.valuesForLink(at: indexPath)
    case PublishMenuViewController.Section.preview.rawValue:
      (title, image) = self.valuesForPreview(at: indexPath)
    case PublishMenuViewController.Section.publish.rawValue:
      (title, image) = self.valuesForPublish(at: indexPath)
    default:
      return  ((nil, nil),nil)
    }
    return ((title, image), (name, profileImage, count))
  }
}
