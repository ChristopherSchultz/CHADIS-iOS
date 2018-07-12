//
//  staticQuestView.swift
//  CHADIS
//
//  Created by Paxon Yu on 7/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit



struct questTypes: Decodable {
    var displaytype: String
    var id: Int //
    var layout: String
    var multiplicity: String
    var options: [option]
    
}

struct option: Decodable {
    
   // var freeResponse: Int?
    var freeResponseDataType: String?
    var freeResponseErrorText: String?
    var freeResponseRegexp: String?
    var id: Int //
    var order: Int //
    var text: String
    var value: Int //
    
}

struct questionnaire: Decodable {
    var assigned: String
    var description: String
   // var dynamic: Int //
    var id: Int //
    var introduction: String?
    var locale: String
    var name: String
    var questionnaire_id: Int //
    var questionsPerPage: Int //
    var started: String
}

struct questions: Decodable {
    var id: Int //
    var text: String
    var type: Int //
}

struct questionJSON: Decodable{
    var questionTypes: [questTypes]
    var questionnaire: questionnaire
    var questions: [questions]
}




class staticQuestView: UIViewController {
    
    var status: Int!
    var pqid: Int!
    var sessionid: String!
    var patient: Patient!
    var questid: Int!
    var masterQuestion: questionJSON?
    var questionArray:[questions]?
    
    
    @IBOutlet weak var introductionLabel: UILabel!
    @IBAction func sendToQuestion(_ sender: Any) {
        let controller = questionView()
        controller.questionArray = self.questionArray
        controller.index = 0
        controller.pqid = self.pqid
        controller.masterQuestion = self.masterQuestion
        self.navigationController?.pushViewController(controller, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var url: URL
      
        //something is weird when the status of the questionnaire is 0 because the get questions link
        //and call are working fine when the status is 1
        switch status {
        case 0:
            url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/begin.do?id=\((pqid)!)")!
        case 1:
            url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/continue.do?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do?id=\((pqid)!)")!
        case 3:
            url = URL(string:baseURLString! + "respondent/questionnaire/restart.do?id=\((pqid)!)")!
        default:
            url = URL(string: "https://youtube.com")!
            print("not a default status")
            
        }
        let sem = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        let request = URLRequest(url: url)
        print(url)
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    
                    let stringversion = String.init(data: data, encoding: .utf8)
                    print(stringversion)
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questionJSON.self, from: data)
                    self.masterQuestion = decodeQuest
                    print(json)
                    sem.signal()
                    
                    
                    
                    
                    
                } catch {
                    print(error)
                }
            }
            }.resume()
        sem.wait()
   
        if masterQuestion?.questionnaire.introduction != nil {
        introductionLabel.text = cleanIntro(intro: (masterQuestion?.questionnaire.introduction)!)
        }else{
            introductionLabel.text = "Welcome to the \((masterQuestion?.questionnaire.name)!)"
        }
        introductionLabel.adjustsFontSizeToFitWidth = true
        introductionLabel.baselineAdjustment = .none
        
        introductionLabel.sizeToFit()
        introductionLabel.textAlignment = .left
        questionArray = masterQuestion?.questions
        
        
    }
    
   
    func cleanIntro(intro: String) -> String {
        var result = intro
        // regexp : <\/?\w*> to use
       /*
        var regexp = try! NSRegularExpression(pattern: "<[^.]+>")
        let regexp2 = try! NSRegularExpression(pattern: "<[\\D]+>")
        let range = NSMakeRange(0, result.count)
        let modString = regexp.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "") */

        
        result = intro.replacingOccurrences(of: "<html>", with: "")
        result = result.replacingOccurrences(of: "<p>", with: "")
        result = result.replacingOccurrences(of: "</html>", with: "")
        result = result.replacingOccurrences(of: "</p>", with: "")
        result = result.replacingOccurrences(of: "\n", with: "")
        result = result.replacingOccurrences(of: "<ul>", with: "")
        result = result.replacingOccurrences(of: "<li>", with: "")
        result = result.replacingOccurrences(of: "</li>", with: "")
        result = result.replacingOccurrences(of: "</ul>", with: "")
        result = result.trimmingCharacters(in: .whitespaces)
      
       // print(result)
        return result
    }
}
