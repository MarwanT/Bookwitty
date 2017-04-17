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

class VideoCardViewModel {

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
        IFramely.shared.loadResponseFor(url: url, closure: { (response: Response?) in
          self.videoProperties.url = response?.embedUrl
          self.videoProperties.thumbnail = response?.thumbnails?.first?.url?.absoluteString ?? video.coverImageUrl
          self.notifyChange()
        })
      }
    }
  }

}
