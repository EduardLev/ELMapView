//
//  WebViewController.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/14/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var progressView: UIProgressView!
    var reachability: Reachability?
    var webConfiguration: WKWebViewConfiguration?
    var webView: WKWebView?
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.createNavigationBarButtons()
        self.createProgressView()
        if (self.checkInternetConnection()) {
            self.createWebBrowser()
            self.view.addSubview(self.progressView)
        } else {
            self.presentNoInternetAlert()
        } 
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentNoInternetAlert() {
        let alert = UIAlertController(title: "Error",
                                      message: "No Internet Connection",
                                      preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        progressView.layer.frame = CGRect(x: 0.0, y: 60.0,
                                          width: self.view.frame.size.width, height: 6)
        progressView.trackTintColor = .clear
        progressView.layer.masksToBounds = true
        progressView.clipsToBounds = true
    }
    
    func checkInternetConnection() -> Bool {
        reachability = Reachability()
        if (reachability?.connection != .none) {
            return true
        } else {
            return false
        }
    }
    
    func createWebBrowser() {
        self.createWebConfiguration()
        self.createWebView()
        self.createWebRequest()
    }
    
    func createWebConfiguration() {
        webConfiguration = WKWebViewConfiguration()
    }
    
    func createWebView() {
        let frame = CGRect(x: 0.0, y: 60.0, width: self.view.frame.size.width,
                           height: self.view.frame.size.height - 60)
        webView = WKWebView(frame: frame, configuration:self.webConfiguration!)
        webView?.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView!)
        
        self.webView?.addObserver(self, forKeyPath:"estimatedProgress",
                                  options: .new, context: nil)
        
        self.webView?.uiDelegate = self
    }
    
    func createWebRequest() {
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            self.webView?.load(request)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if (keyPath == "estimatedProgress") {
                self.progressView.isHidden = false
                self.progressView.progress = Float((self.webView?.estimatedProgress)!)
                if self.progressView.progress == 1 {
                    self.progressView.isHidden = true
                }
            }
        }
    }
    

}
