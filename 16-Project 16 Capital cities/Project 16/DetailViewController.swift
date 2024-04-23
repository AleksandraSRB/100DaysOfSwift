//
//  DetailViewController.swift
//  Project 16
//
//  Created by Aleksandra Sobot on 4.1.24..
//

import UIKit
import WebKit
// Challange 3 - Showing new ViewController with a webView, taking user to wikipedia page of that city
class DetailViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    
    var detailCapital: Capital?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailCapital = detailCapital else { return }

        title = detailCapital.title
        
        let urlStr = "https://en.wikipedia.org/wiki/" + detailCapital.wikiString
        let url = URL(string: urlStr)
        webView.load(URLRequest(url: url!))
    }
}
