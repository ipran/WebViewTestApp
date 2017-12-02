//
//  ViewController.swift
//  WebViewTestApp
//
//  Created by Pranil on 11/29/17.
//  Copyright © 2017 pranil. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webViewContainer: UIView!
    fileprivate var openUrl: URL?
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUrl() {
        openUrl = URL(string: "https://app.educationgalaxy.com/games/ipadgame.html?retries=3&name=blastoff&rocket=3&level=2&score=0&gameTimer=150")!
        guard let url = openUrl else { return }
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsLinkPreview = true
        webView.uiDelegate = self
        webViewContainer.addSubview(webView)
        webViewContainer.sendSubview(toBack: webView)
        addConstraints(to: webView, with: webViewContainer)
        webView.load(NSURLRequest(url: url) as URLRequest)
    }
    
    func addConstraints(to webView: UIView, with superView: UIView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1, constant: 0)
        superView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }

}

extension ViewController: WKNavigationDelegate,WKUIDelegate
{

    func webView(_: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        debugPrint("didFailProvisionalNavigation: \(navigation), error: \(error)")
        
        guard let failingUrlStr = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String else { return }
        let failingUrl = URL(string: failingUrlStr)!
        
        switch failingUrl {
        // Needed to open Facebook
        case _ where failingUrlStr.contains("fb:"):
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(failingUrl, options: [:], completionHandler: nil)
                return
            } // Else: Do nothing, iOS 9 and earlier will handle this
            
        // Needed to open Mail-app
        case _ where failingUrlStr.contains("mailto:"):
            UIApplication.shared.open(failingUrl, options: [:], completionHandler: nil)
            return
            
        // Needed to open Appstore-App
        case _ where failingUrlStr.contains("itmss://itunes.apple.com/"):
            if UIApplication.shared.canOpenURL(failingUrl) {
                UIApplication.shared.open(failingUrl, options: [:], completionHandler: nil)
                return
            }
            
        default: break
        }
    }
    
    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        // if <a> tag does not contain attribute or has _blank then navigationAction.targetFrame will return nil
        if let trgFrm = navigationAction.targetFrame {
            
            if !trgFrm.isMainFrame {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                webView.load(navigationAction.request)
            }
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func webView(_: WKWebView, decidePolicyFor _: WKNavigationResponse, decisionHandler: @escaping (_: WKNavigationResponsePolicy) -> Void) {
        
        debugPrint("decidePolicyForNavigationResponse")
        decisionHandler(.allow)
    }
    
    func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction, decisionHandler: @escaping (_: WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
}

