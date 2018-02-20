//
//  RichEditorView+Actions.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import RichEditorView
import SwiftyJSON

extension RichEditorView {
  func generate(quote: String, author: String, citeText: String, citeUrl: String) {
    let functionName = "RE.generateQuote"
    let parameters = [quote, author, citeText, citeUrl]
    
    callJavascript(with: functionName, and: parameters, completion: nil)
  }
  
  func generate(photo: URL?, alt: String?, wrapperId: String) {
    let functionName = "RE.generatePhoto"
    let parameters = [photo?.absoluteString, alt, wrapperId]
    
    callJavascript(with: functionName, and: parameters, completion: nil)
  }
  
  func generate(link href: URL?, text: String?) {
    let functionName = "RE.generateLink"
    let parameters = [href?.absoluteString, text]
    
    callJavascript(with: functionName, and: parameters, completion: nil)
  }
  
  func generateLinkPreview(type: String?, title: String?, description: String?, url: URL?, imageUrl: URL?, html: String?) {
    let functionName = "RE.generateLinkPreview"
    let parameters = [type, title, description, url?.absoluteString, imageUrl?.absoluteString, html]
    
    callJavascript(with: functionName, and: parameters, completion: nil)

  }
  
  func generate(embed: String?) {
    let functionName = "RE.generateEmbed"
    let parameters = [embed]
    
    callJavascript(with: functionName, and: parameters, completion: nil)
  }
  
  func setHeader() {
    runJS("RE.setHeader();", completion: nil)
  }
  
  func generatePhotoWrapper(completion: @escaping (String) -> Void) {
    return runJS("RE.generatePhotoWrapper();", completion: completion)
  }
  
  func enabledCommands(completion: @escaping ([String]) -> Void) {
    return runJS("RE.enabledCommands()") { jsResult in
      completion(jsResult.components(separatedBy: ","))
    }
  }
  
  func setContent(html: String?) {
    guard let html = html?.base64Encoded else {
      runJS("RE.setContent('')", completion: nil)
      return
    }
    runJS("RE.setContent(\'\(html)\')", completion: nil)
  }
  
  func getContent(completion: @escaping (String) -> Void) {
    runJS("RE.getContent();", completion: completion)
  }
  
  func selectedHref(completion: @escaping (String) -> Void) {
    runJS("RE.getSelectedHref()", completion: completion)
  }
  
  func getDefaults(completion: @escaping (_ title: String, _ description: String?, _ imageURL: String?) -> Void) {
    runJS("RE.getDefaults();") { (jsResult) in
      let values = self.parseDefaultContent(jsResult)
      completion(values.title, values.description, values.imageURL)
    }
  }
  
  func hasFocus(completion: @escaping (Bool) -> Void) {
    runJS("RE.hasFocus();") { (jsResult) in
      completion(jsResult == "true")
    }
  }
  
  func backupRange() {
    runJS("RE.backupRange();", completion: nil)
  }
}

extension RichEditorView {
  /// Sanitize JS Call
  func callJavascript(with functionName:String, and parameters:[String?], completion: ((String) -> Void)?) {
    //Here we are checking for nil in order to preserve the parameters original order
    let sanitizedParameters = parameters.map { $0 == nil ? "" : $0! }.map{ $0.trimmed }.map { $0.base64Encoded ?? "" }
    let sanitizedJoinedParameters = sanitizedParameters.joined(separator: "\',\'")
    
    var javaScriptString = functionName + "("
    
    //Only if we have parameters we add them
    //this check here to prevent adding additional empty string parameter `('')` to the function we are calling
    if sanitizedParameters.count > 0 {
      javaScriptString += "\'" + sanitizedJoinedParameters + "\'"
    }
    
    javaScriptString += ")"
    runJS(javaScriptString, completion: completion)
  }
}

fileprivate extension RichEditorView {

  func parseDefaultContent(_ jsonString: String) -> (title: String, description: String?, imageURL: String?) {
    let json: JSON = JSON(parseJSON: jsonString)
    let title = json["title"].stringValue
    let description = json["description"].string
    let imageURL = json["image"].string
    return (title, description, imageURL)
  }
}
