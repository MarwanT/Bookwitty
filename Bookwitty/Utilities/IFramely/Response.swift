//
//  Response.swift
//  iframely
//
//  Created by charles on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Response {
  let author: String?
  let title: String?
  let duration: TimeInterval?
  let shortDescription: String?
  let site: String?
  let html: String?

  let url: URL?
  var embedUrl: URL? {
    return medias?.first?.url
  }
  
  let medias: [Media]?
  let thumbnails: [Thumbnail]?

  internal init?(data: Data?) {
    guard let data = data else {
      return nil
    }

    let json: JSON = JSON(data: data)
    self.init(json: json)
  }

  private init(json: JSON) {
    self.author = json["meta"]["author"].string
    self.title = json["meta"]["title"].string
    self.duration = json["meta"]["duration"].double
    self.shortDescription = json["meta"]["description"].string
    self.site = json["meta"]["site"].string

    self.url = URL(string: json["meta"]["canonical"].stringValue)
    self.medias = json["links"]["player"].array?.map({ Media(json: $0) })
    self.thumbnails = json["links"]["thumbnail"].array?.map({ Thumbnail(json: $0) })
    self.html = json["html"].string
  }
}
