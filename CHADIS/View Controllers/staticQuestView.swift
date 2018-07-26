//
//  staticQuestView.swift
//  CHADIS
//
//  Created by Paxon Yu on 7/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

//The following structs are used to decode the JSON data for the questionnaires

struct questTypes: Decodable {
    var displaytype: String
    var id: Int //
    var layout: String
    var multiplicity: String
    var options: [option]
    
}

struct option: Decodable {
    
    //var freeResponse: Bool?
    var freeResponseDataType: String?
    var freeResponseErrorText: String?
    var freeResponseRegexp: String?
    var id: Int //
    var mutuallyExclusive: Bool?
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



/* This class is used to show the introduction to the questionnaire provided that it exists and it preps
 the questions for the questionnaire */
class staticQuestView: UIViewController {
    
    var status: Int!
    var pqid: Int!
    var sessionid: String!
    var patient: Patient!
    var questid: Int!
    var masterQuestion: questionJSON?
    var questionArray:[questions]?
    
    
    @IBOutlet weak var introductionLabel: UILabel!
    
    //This action sends the user to the first question while passing in relevant information
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
        
        //Switch statement that determines what URL call to make
        switch status {
        case 0:
            url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/begin.do?id=\((pqid)!)")!
        case 1:
            url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/continue.do?id=\((pqid)!)")!
        case 2:
            url = URL(string: baseURLString! + "respondent/questionnaire/review.do?id=\((pqid)!)")!
        case 3:
            url = URL(string: baseURLString! + "respondent/questionnaire/restart.do?id=\((pqid)!)")!
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
                    print( "STRING VERSION " + stringversion!)
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questionJSON.self, from: data)
                    self.masterQuestion = decodeQuest
                    print(json)
                    sem.signal()
                    
                    
                } catch {
                    let stringData = String.init(data: data, encoding: String.Encoding.utf8)
                    print(stringData)

                    print(error)
                }
            }
            }.resume()
        sem.wait()
   
        //This block of code provides a default introduction if one does not exist
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
    
   
    //This function cleans up all of the HTML tags from a string
    //TO DO: utilize regular expressions to make this code more useful
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
