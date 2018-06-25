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

class QuestWebView: UIViewController, WKScriptMessageHandler, UIWebViewDelegate, WKUIDelegate {
   
    
    
    @IBOutlet weak var questView: WKWebView!
    var status: Int!
    var pqid: Int!
    var sessionid: String!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url: URL
        switch status {
            case 0:
                url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 1:
            url = URL(string: baseURLString! + "respondent/questionnaire/resume.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 3:
            url = URL(string:baseURLString! + "/respondent/questionnaire/restart.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        default:
            url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            print("not a default status")
            
        }
        print(url)
        questView.load(URLRequest(url: url))
        
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("I get run")
        questView.evaluateJavaScript("confirmQuit(thisform,quitmessage)", completionHandler: nil)
        NSLog("request: \(request)")
        return true
    }
   
    
    
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
}
