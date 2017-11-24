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
    
    callJavascript(with: functionName, and: parameters)
  }
  
  func generate(photo: URL?, alt: String?, wrapperId: String) {
    let functionName = "RE.generatePhoto"
    let parameters = [photo?.absoluteString, alt, wrapperId]
    
    callJavascript(with: functionName, and: parameters)
  }
  
  func generate(link href: URL?, text: String?) {
    let functionName = "RE.generateLink"
    let parameters = [href?.absoluteString, text]
    
    callJavascript(with: functionName, and: parameters)
  }
  
  func generateLinkPreview(type: String?, title: String?, description: String?, url: URL?, imageUrl: URL?, html: String?) {
    let functionName = "RE.generateLinkPreview"
    let parameters = [type, title, description, url?.absoluteString, imageUrl?.absoluteString, html]
    
    callJavascript(with: functionName, and: parameters)

  }
  
  func generate(embed: String?) {
    let functionName = "RE.generateEmbed"
    let parameters = [embed]
    
    callJavascript(with: functionName, and: parameters)
  }
  
  func setHeader() {
    runJS("RE.setHeader();")
  }
  
  func generatePhotoWrapper() -> String {
    return runJS("RE.generatePhotoWrapper();")
  }
  
  func enabledCommands() -> [String] {
    return runJS("RE.enabledCommands()").components(separatedBy: ",")
  }
  
  func setContent(html: String?) {
    let functionName = "RE.setContent"
    let parameters = [html]
  
    callJavascript(with: functionName, and: parameters)
  }
  
  func getContent() -> String {
    return runJS("RE.getContent();")
  }
  
  func selectedHref() -> String {
    return runJS("RE.getSelectedHref()")
  }
  
  func getDefaults() -> (title: String, description: String?) {
    let jsonString =  runJS("RE.getDefaults();");
    return parseDefaultContent(jsonString)
  }
}

extension RichEditorView {
  /// Sanitize JS Call
  func callJavascript(with functionName:String, and parameters:[String?]) {
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
    runJS(javaScriptString)
  }
}

fileprivate extension RichEditorView {

  func parseDefaultContent(_ jsonString: String) -> (title: String, description: String?) {
    let json: JSON = JSON(parseJSON: jsonString)
    let title = json["title"].stringValue
    let description = json["description"].string
    return (title, description)
  }
}
