//
//  AppMeta.swift
//  Bookwitty
//
//  Created by Marwan  on 3/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppMeta {
  var minimumAppVersion: String?
  var storeURLString: String?
  var latestAPIVersion: String?
  var thisAPIVersion: String?
}

extension AppMeta {
  static func appMeta(for data: Data) -> AppMeta? {
    guard let jsonDictionary = try? JSONSerialization.jsonObject(
      with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] else {
        return nil
    }
    
    let appMeta = AppMeta()
    let json = JSON(jsonDictionary)
    let metaJSON = json["meta"]
    appMeta.minimumAppVersion = metaJSON["ios"]["minimum_app_version"].string
    appMeta.storeURLString = metaJSON["ios"]["store_url"].string
    appMeta.latestAPIVersion = metaJSON["latest_api_version"].string
    appMeta.thisAPIVersion = metaJSON["this_api_version"].string
    return appMeta
  }
}
