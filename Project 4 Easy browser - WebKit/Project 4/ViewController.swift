//
//  ViewController.swift
//  Project 4
//
//  Created by Aleksandra Sobot on 24.2.23..
//

import UIKit
import WebKit

class ViewController: UITableViewController, WKNavigationDelegate {

    var websites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Web pages"
        
        if let startURL = Bundle.main.url(forResource: "webpageList", withExtension: "txt") {
                   if let websitesInDoc = try? String(contentsOf: startURL) {
                       websites = websitesInDoc.components(separatedBy: "\n")
                   }
               }
    }
    // Challange 3. - Making a tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        websites.count
    }
    // Challange 3. - Making a tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "websites", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    // Challange 3. - Making a tableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WebView") as? WebViewViewController {
            vc.websites = websites
            vc.selectedWebsite = websites[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


   
