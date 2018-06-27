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

class QuestWebView: UIViewController, WKScriptMessageHandler, UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate{
   
    
    @IBOutlet weak var questView: WKWebView!
    var status: Int!
    var pqid: Int!
    var sessionid: String!
    var patient: Patient!
   
    @IBAction func popButton(_ sender: Any) {
        let views = self.navigationController?.viewControllers as! [UIViewController]
        self.navigationController?.popToViewController(views[views.count - 3], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questView.uiDelegate = self
        questView.navigationDelegate = self
        var url: URL
        switch status {
        case 0:
            url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 1:
            url = URL(string: baseURLString! + "respondent/questionnaire/resume.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
        case 3:
            url = URL(string:baseURLString! + "respondent/questionnaire/restart.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
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
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("BASE:")
        print(questView.url!)
        
        let checknext = URL(string: baseURLString! + "respondent/questionnaire/check-next.do;jsessionid=\((sessionid)!)?id=\((patient.id))")
        let view = URL(string: baseURLString! + "respondent/questionnaires/view.do;jsessionid=\((sessionid)!)?id=\(patient.id)")
        let url = questView.url!
        if url == checknext || url == view {
            decisionHandler(.cancel)
            let views = self.navigationController!.viewControllers 
            self.navigationController?.popToViewController(views[views.count - 3], animated: true)
        }else{
            decisionHandler(.allow)
            print("CHECK NEXT:")
            print(checknext!)
            print("VIEW:")
            print(view!)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
}
