//
//  QuestWebView.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/12/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class QuestWebView: UIViewController, WKScriptMessageHandler, UIWebViewDelegate {
   
    
    
    @IBOutlet weak var questView: WKWebView!
    var status: Int!
    var pqid: Int!
    var sessionid: String!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(self, name: "JSListener")
        configuration.userContentController = controller
        let webview = WKWebView(frame: self.view.frame, configuration: configuration)
        self.view = webview
        
        var url: URL
        switch status {
            case 1:
                url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/resume.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 3:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            
        default:
            url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            print("not a default status")
            
        }
        print(url)
        webview.load(URLRequest(url: url))
        //questView.load(URLRequest(url: url))
        
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        NSLog("request: \(request)")
        return true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        <#code#>
    }
    
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
}
