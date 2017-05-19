//
//  WebViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 5/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import FLKAutoLayout

protocol WebViewControllerDelegate: class {
  func webViewController(_ webViewController: WebViewController, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
  func webViewController(_ webViewController: WebViewController, didFailLoadWithError error: Error)
  func webViewControllerDidStartLoad(_ webViewController: WebViewController)
  func webViewControllerDidFinishLoad(_ webViewController: WebViewController)
}

class WebViewController: UIViewController {
  let webView: UIWebView = UIWebView()
  let textField: UITextField = UITextField()
  
  var configuration = Configuration()
  
  weak var delegate: WebViewControllerDelegate? = nil
  
  private var url: URL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(webView)
    setupWebView()
    setupNavigationBar()
    
    if let url = url {
      loadURL(url: url)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // Set the textField size otherwise its frame is CGRect.zero
    resizeTextField()
  }
  
  func resizeTextField() {
    var textFieldFrame = textField.frame
    let leftBarButtonFrame = navigationItem.leftBarButtonItem?.frame ?? CGRect.zero
    textFieldFrame.size.width = (navigationController?.navigationBar.frame.width ?? 100) - (leftBarButtonFrame.width + (leftBarButtonFrame.origin.x * 3))
    textFieldFrame.size.height = 35
    textField.frame = textFieldFrame
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
  
  fileprivate func display(url: URL?) {
    textField.text = url?.host
  }
  
  func loadURL(url: URL) {
    self.url = url
    display(url: url)
    webView.loadRequest(URLRequest(url: url))
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
    let shouldStartLoad = delegate?.webViewController(self, shouldStartLoadWith: request, navigationType: navigationType) ?? true
    if shouldStartLoad {
      display(url: request.url)
    }
    return shouldStartLoad
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    delegate?.webViewController(self, didFailLoadWithError: error)
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    delegate?.webViewControllerDidStartLoad(self)
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    delegate?.webViewControllerDidFinishLoad(self)
  }
}

// MARK: - Presenting methods
extension WebViewController {
  public static func present(url: URL, delegate: WebViewControllerDelegate? = nil, inViewController: UIViewController? = nil) {
    let presenterViewController: UIViewController = inViewController != nil ? inViewController! : rootViewController
    let webVC = WebViewController()
    webVC.delegate = delegate
    webVC.loadURL(url: url)
    let navigationVC = UINavigationController(rootViewController: webVC)
    presenterViewController.present(navigationVC, animated: true, completion: nil)
  }
  
  private static var rootViewController: UIViewController {
    guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
      fatalError("No root view controller detected")
    }
    return rootViewController
  }
}
