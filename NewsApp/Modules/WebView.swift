//
//  WebView.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/27/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    var stringURL = "http://nytimes.com"
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        if let url = URL(string: stringURL) {
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
    }
    



}
