//
//  webViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/4/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit
import WebKit


/*T his is a general webview controller intended to handle two cases, the event that the user has logged on
 successfully and wishes to view the website via webview or the case where the user has not logged on
 */
class webViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var urlString: String? //This variable determines which url to visit
    var loggedIn: Bool! //this variable determines whether the user is already logged in or not
    var username: String?
    var password: String?
    
    //since the webview is the only object on this page, I only need to use view did load
    override func viewDidLoad() {
        let url = URL(string: urlString!)
        super.viewDidLoad()
        var request: URLRequest!
        
        //if the user is logged in then do a bunch of things in regards to the request
        if loggedIn {
            request = URLRequest(url: url!)
            let parameters = ["username": username!, "password": password!]
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
        }else{
            request = URLRequest(url: url!)
        }
        webView.load(request) //displays the request
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

