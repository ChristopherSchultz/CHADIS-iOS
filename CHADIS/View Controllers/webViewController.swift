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

class webViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var urlString: String?
    var loggedIn: Bool!
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        let url = URL(string: urlString!)
        super.viewDidLoad()
        var request: URLRequest!
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
        webView.load(request)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

