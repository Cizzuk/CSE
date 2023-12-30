//
//  ViewController.swift
//  Custom Search Engine
//
//  Created by tsg0o0 on 2022/07/23.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self

        self.webView.configuration.userContentController.add(self, name: "controller")

        self.webView.loadFileURL(Bundle.main.url(forResource: "Main", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(boldTextStatusDidChangeNotification(notification:)), name: UIAccessibility.boldTextStatusDidChangeNotification, object: nil)
        if #available(iOS 14.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(buttonShapesEnabledStatusDidChangeNotification(notification:)), name: UIAccessibility.buttonShapesEnabledStatusDidChangeNotification, object: nil)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url!.absoluteString.prefix(7) == "file://"{
            decisionHandler(.allow)
        }else{
            if navigationAction.request.url!.absoluteString == "cse://settings"{
                self.performSegue(withIdentifier: "settings", sender: self)
            }else if navigationAction.request.url!.absoluteString == "https://tsg0o0.com/" || navigationAction.request.url!.absoluteString == "https://www.mozilla.org/en-US/MPL/2.0/"{
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
        }
            
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Override point for customization.
    }
    
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return false
        } else {
            return true
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if UIAccessibility.isBoldTextEnabled {
            webView.evaluateJavaScript("window.setTimeout(\"isBoldTextEnabled(true);\", 200);")
        }
        if #available(iOS 14.0, *) {
            if UIAccessibility.buttonShapesEnabled {
                webView.evaluateJavaScript("window.setTimeout(\"buttonShapesEnabled(true);\", 200);")
            }
        }
    }
    
    @objc private func boldTextStatusDidChangeNotification(notification: Notification) {
        if UIAccessibility.isBoldTextEnabled {
            webView.evaluateJavaScript("isBoldTextEnabled(true);")
        }else{
            webView.evaluateJavaScript("isBoldTextEnabled(false);")
        }
    }
    @objc private func buttonShapesEnabledStatusDidChangeNotification(notification: Notification) {
        if #available(iOS 14.0, *) {
            if UIAccessibility.buttonShapesEnabled {
                webView.evaluateJavaScript("buttonShapesEnabled(true);")
            }else{
                webView.evaluateJavaScript("buttonShapesEnabled(false);")
            }
        }
    }

}
