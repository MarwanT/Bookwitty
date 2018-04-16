//
//  AppError.swift
//  Bookwitty
//
//  Created by Marwan  on 3/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppError {
  var status: Int?
  var detail: String?
  var meta: [String: Any]?
  var code: String?
}

extension AppError {
  static func appError(for jsonObject: JSON) -> AppError {
    let appError = AppError()
    appError.status = jsonObject["status"].int
    appError.detail = jsonObject["detail"].string
    appError.meta = jsonObject["meta"].dictionaryObject
    appError.code = jsonObject["code"].string
    return appError
  }
  
  static func appErrors(for data: Data) -> [AppError]? {
    guard let jsonDictionary = try? JSONSerialization.jsonObject(
      with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
        return nil
    }
    
    var errors = [AppError]()
    let json = JSON(jsonDictionary)
    let errorsJSON = json["errors"].arrayValue
    for jsonObject in errorsJSON {
      let error = appError(for: jsonObject)
      errors.append(error)
    }
    return errors
  }
}
