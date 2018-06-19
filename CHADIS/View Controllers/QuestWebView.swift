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

class QuestWebView: UIViewController {
    
    
    @IBOutlet weak var questView: WKWebView!
    var status: Int!
    var pqid: Int!
    var sessionid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        questView.load(URLRequest(url: url))
        
    }
    
    
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
}
