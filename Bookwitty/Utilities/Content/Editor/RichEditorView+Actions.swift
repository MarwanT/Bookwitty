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
    runJS("RE.generateQuote(\"\(quote)\", \"\(author)\", \"\(citeText)\", \"\(citeUrl)\");")
  }
  
  func generate(photo: URL?, alt: String?) {
    runJS("RE.generatePhoto(\"\(photo?.absoluteString ?? "" )\", \"\(alt ?? "")\");")
  }
  
  func generate(link href: URL?, text: String?) {
    runJS("RE.generateLink(\"\(href?.absoluteString ?? "" )\", \"\(text ?? "" )\");")
  }
  
  func generateLinkPreview(type: String?, title: String?, description: String?, url: URL?, imageUrl: URL?) {
    runJS("RE.generateLinkPreview(\"\(type ?? "")\", \"\(title ?? "")\", \"\(description ?? "")\", \"\(description ?? "")\", \"\(url?.absoluteString ?? "")\", \"\(imageUrl?.absoluteString ?? "")\");")
  }
  
  func generate(embed: String?) {
    runJS("RE.generateEmbed(\"\(embed ?? "")\");")
  }
}
