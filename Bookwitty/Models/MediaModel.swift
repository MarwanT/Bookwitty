//
//  MediaModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class MediaModel: NSObject {
  private struct MediaKey {
    private init(){}
    static let sourceLink = "source_link"
    static let sourceName = "source_name"
    static let mediaLink = "media_link"
  }
  var sourceLink: String?
  var sourceName: String?
  var mediaLink: String?

  override init() {
    super.init()
  }

  init(for dictionary: [String : Any]) {
    super.init()
    setValues(dictionary: dictionary)
  }

  private func setValues(dictionary: [String : Any]) {
    self.sourceLink = (dictionary[MediaKey.sourceLink] as? String)
    self.sourceName = (dictionary[MediaKey.sourceName] as? String)
    self.mediaLink = (dictionary[MediaKey.mediaLink] as? String)
  }

  override var debugDescription: String {
    let str1: String = "Media: sourceLink: \(sourceLink)"
    let str2: String =  "sourceName: \(sourceName)"
    let str3: String = "mediaLink: \(mediaLink)"
    let str: String = str1 + " || " + str2 + " || " + str3
    return str
  }
}
