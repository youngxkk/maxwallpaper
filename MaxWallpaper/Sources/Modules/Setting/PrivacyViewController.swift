//
//  PrivacyViewController.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/9/25.
//  Copyright © 2018年 elijah. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController,WKUIDelegate, WKNavigationDelegate {
    
    //设置一个webview
    lazy private var webview: WKWebView = {
        self.webview = WKWebView.init(frame: self.view.bounds)
        self.webview.uiDelegate = self as WKUIDelegate
        self.webview.navigationDelegate = self as WKNavigationDelegate
        return self.webview
    }()

    
    //添加一个进度监听
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: 4))
        self.progressView.tintColor = HexColor(hex: 0xFF0073, alpha: 1.0)
        self.progressView.trackTintColor = UIColor.black
        return self.progressView
    }()
    
    //视图加载
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.backgroundColor = UIColor.black
        view.addSubview(webview)
        view.addSubview(progressView)
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webview.load(URLRequest.init(url: URL.init(string: "https://youngxkk.github.io/about/about.html")!))    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float(webview.estimatedProgress), animated: true)
            if webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.66,  //动效总时间
                                delay: 0,  //延迟时间
                                usingSpringWithDamping: 0.86, //弹簧的值，0~1，越小弹性越大
                                initialSpringVelocity: 20, //初始速度0~100
                                options: .allowUserInteraction,
                               animations: {
                                self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    
    //监听事件
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {        print("开始加载")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("开始获取网页内容")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载完成")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {        print("加载失败")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow);
    }
    
    //ReceiveMemory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //我也不知道这是干啥的
    deinit {
        webview.removeObserver(self, forKeyPath: "estimatedProgress")
        webview.uiDelegate = nil
        webview.navigationDelegate = nil
    }
    
}
