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
    var questid: Int!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questView.uiDelegate = self
        questView.navigationDelegate = self
        var url: URL
        var url2: URL
        switch status {
        case 0:
            url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            url2 = URL(string: baseURLString! + "respondent/api/patient/questionnaire/begin.do?id=\((pqid)!)")!
        case 1:
            url = URL(string: baseURLString! + "respondent/questionnaire/resume.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            url2 = URL(string: baseURLString! + "respondent/api/patient/questionnaire/continue.do?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            url2 = URL(string: baseURLString! + "respondent/questionnaire/review.do?id=\((pqid)!)")!
        case 3:
            url = URL(string:baseURLString! + "respondent/questionnaire/restart.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            url2 = URL(string:baseURLString! + "respondent/questionnaire/restart.do?id=\((pqid)!)")!
        default:
            url = URL(string: baseURLString! + "respondent/questionnaire/start.do;jsessionid=\((sessionid)!)?id=\((pqid)!)")!
            url2 = URL(string: "https://youtube.com")!
            print("not a default status")
            
        }
        print("URL 1 : \(url)")
        print("URL 2: \(url2)")
        questView.load(URLRequest(url: url))
        
        let session = URLSession.shared
        var request = URLRequest(url: url2)
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    //let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)
                    print("DECODE:")
                    print(json)
                    
                    
                   
                } catch {
                    print(error)
                }
            }
            }.resume()
      
        
        
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    
    func test(){
        let sem = DispatchSemaphore(value: 0)
        let id = "?id=\((pqid)!)"
        let url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/continue.do" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let session = URLSession.shared
       
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)
                    print("DECODE:")
                    print(decodeQuest)
                
                    
                    sem.signal()
                } catch {
                    print(error)
                }
            }
            }.resume()
        sem.wait()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
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
        
        let checknext = URL(string: baseURLString! + "respondent/questionnaire/check-next.do;jsessionid=\((sessionid)!)?id=\((patient.id))")
        let view = URL(string: baseURLString! + "respondent/questionnaires/view.do;jsessionid=\((sessionid)!)?id=\(patient.id)")
        let url = questView.url!
        if url == checknext || url == view {
            decisionHandler(.cancel)
            let views = self.navigationController!.viewControllers 
            self.navigationController?.popToViewController(views[views.count - 3], animated: true)
        }else{
            decisionHandler(.allow)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
}
