//
//  WebViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 5/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import FLKAutoLayout

class WebViewController: UIViewController {
  let webView: UIWebView = UIWebView()
  let textField: UITextField = UITextField()
  
  var configuration = Configuration()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(webView)
    setupWebView()
    setupNavigationBar()
  }
  
  private func setupWebView() {
    // Setup layout
    webView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: view)
    
    // Set Delegate
    webView.delegate = self
  }
  
  private func setupNavigationBar() {
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneBarButtonTouchUpInside(_:)))
    self.navigationItem.leftBarButtonItem = doneBarButton
    
    textField.isUserInteractionEnabled = false
    textField.textAlignment = NSTextAlignment.center
    textField.textColor = configuration.textFieldTextColor
    textField.borderStyle = UITextBorderStyle.roundedRect
    let rightBarButton = UIBarButtonItem(customView: textField)
    self.navigationItem.rightBarButtonItem = rightBarButton
  }
  
  // MARK: Actions
  func doneBarButtonTouchUpInside(_ sender: Any?) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Configuration Struct Declaration
extension WebViewController {
  struct Configuration {
    var textFieldTextColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }
}

// MARK: - UIWebViewDelegate
extension WebViewController: UIWebViewDelegate {
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    return true
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
  }
}

