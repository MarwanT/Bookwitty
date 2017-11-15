//
//  RichEditorView+Actions.swift
//  Bookwitty
//
//  Created by ibrahim on 9/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import RichEditorView

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
    runJS("RE.generateLink(\"\(href?.absoluteString ?? "" )\", \"\(text ?? "" )\");")
  }
  
  func generateLinkPreview(type: String?, title: String?, description: String?, url: URL?, imageUrl: URL?, html: String?) {
    let function = "RE.generateLinkPreview(\"\(type ?? "")\", \"\(title ?? "")\", \"\(description ?? "")\", \"\(url?.absoluteString ?? "")\", \"\(imageUrl?.absoluteString ?? "")\", \"\(html ?? "")\");"
    runJS(function)
  }
  
  func generate(embed: String?) {
    runJS("RE.generateEmbed(\"\(embed ?? "")\");")
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
}

extension RichEditorView {
  /// Sanitize JS Call
  func callJavascript(with functionName:String, and parameters:[String?]) {
    //Here we are checking for nil in order to preserve the parameters original order
    let sanitizedParameters = parameters.map { $0 == nil ? "" : $0! }.map{ $0.trimmed }
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
