//
//  VideoCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol VideoCardViewModelDelegate: class {
  func resourceUpdated(viewModel: VideoCardViewModel)
}

class VideoCardViewModel: CardViewModelProtocol {

  var resource: ModelCommonProperties? {
    didSet {
      getVideoInfo()
      notifyChange()
    }
  }

  private var videoProperties: (mediaLink: String?, url: URL?, thumbnail: String?) = (nil, nil, nil)

  weak var delegate: VideoCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  private func getVideoInfo() {
    guard let video = resource as? Video else {
      return
    }

    if let urlStr = video.media?.mediaLink,
      let url = URL(string: urlStr) {
      if videoProperties.mediaLink != urlStr {
        videoProperties.mediaLink = urlStr
        IFramely.shared.loadResponseFor(url: url, closure: { (success: Bool, response: Response?) in
          self.videoProperties.url = response?.embedUrl
          self.videoProperties.thumbnail = response?.thumbnails?.first?.url?.absoluteString ?? video.coverImageUrl
          self.notifyChange()
        })
      }
    }
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (title: String?, description: String?, topComment: Comment?, comments: String?, tags: [String]?, properties: (url: URL?, thumbnail: String?), wit: (is: Bool, count: Int, info: String?)), reported: Reported) {
    guard let resource = resource else {
      return (false, nil, content: (nil, nil, nil, nil, nil, properties: (nil, nil), wit: (false, 0, nil)), .not)
    }

    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = resource.createdAt?.formatted() ?? ""
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }

    let infoNode: Bool = !(cardPostInfoData?.name.isEmpty ?? true)
    let title = resource.title
    let description = resource.shortDescription
    let comments: String? = nil
    let topComment: Comment? = resource.topComments?.first
    let tags = resource.tags?.flatMap({ $0.title })
    let properties = (self.videoProperties.url, self.videoProperties.thumbnail)
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0, resource.witters)
    let reported: Reported = DataManager.shared.isReported(resource as? ModelResource)

    return (infoNode, cardPostInfoData, content: (title, description, topComment, comments, tags, properties, wit: wit), reported: reported)
  }

}
