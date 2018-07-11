//
//  questionView.swift
//  CHADIS
//
//  Created by Paxon Yu on 7/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit


var currParams = [String:Int]()

struct questionOptions {
    var button: UIButton?
    var text: UITextField?
    var isSelected = false
}

/* This view controller is responsible for displaying a single question on the screen at a time. It
 also includes some overhead that allows for passing of information between screens. Everything is programatically
 coded so no storyboard use is involved. */
class questionView: UIViewController, UINavigationControllerDelegate {
    
    var index: Int!
    var questionArray: [questions]!
    var masterQuestion: questionJSON!
    var questionText: String?
    var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        return label
    }()
    var mainOptions = [questionOptions]()
    var pqid: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Question \(index + 1)"
        self.view.backgroundColor = UIColor.white
       
        self.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.baselineAdjustment = .none
        label.adjustsFontSizeToFitWidth = true
        label.text = questionArray[index].text
        label.sizeToFit()
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        generateOptions()
        displayAnswer()
        
        var display = UIButton(frame: CGRect(x: 200, y: 200, width: 200, height: 50))
        display.addTarget(self, action: #selector(questionView.printParams(sender:)), for: UIControlEvents.touchUpInside)
        display.setTitle("Display", for: .normal)
        display.backgroundColor = UIColor.purple
        self.view.addSubview(display)
        
        
        if index != questionArray.count - 1{
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(questionView.next(sender:)))
        self.navigationItem.rightBarButtonItem = nextButton
        }else{
            let submitButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(questionView.submit(sender:)))
            self.navigationItem.rightBarButtonItem = submitButton
            print(currParams)
            
        }
        
        if index > 0{
            let backButton = UIBarButtonItem(title: "Back2", style: .plain, target: self, action: #selector(questionView.back(sender:)))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        
        
    }
    
    
    
    
    func generateOptions() {
        let questionType = questionArray[index].type
        var indexOpt = 0
        var options = [option]()
        var questType: questTypes!
        for questT in masterQuestion.questionTypes{
            if questT.id == questionType {
                questType = questT
                options = questT.options
            }
        }
        for option in options {
            var opt = questionOptions()
            if option.freeResponseDataType  == nil {
            let button = UIButton(frame: CGRect(x: 25, y: 300 + indexOpt * 100, width: 100, height: 50))
           // button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.blue
            button.setTitle("\(option.text)", for: .normal)
            button.addTarget(self, action: #selector(questionView.isSelected(sender:)), for: UIControlEvents.touchUpInside)
            opt.button = button
            mainOptions.append(opt)
            self.view.addSubview(button)
            indexOpt = indexOpt +  1
            }else{
                
            }
            
        }
        
        
    }
    
    
    func submitQuestion() {
        let url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/answer-questions.do?id=\(pqid!)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
       // let params = ["response_\(currQuest)": getAnswer()]
        let params = currParams
        print(params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {return}
        request.httpBody = httpBody
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                   // let decodeQuest = try JSONDecoder().decode(questionJSON.self, from: data)
                   
                    print(json)
                
                    
                    
                    
                    
                    
                } catch {
                    print(error)
                }
            }
            }.resume()
                         
    }
    
    func getAnswer() -> Int{
        var ansIndex = -1
        if getQuestionType().multiplicity == "single"{
            for i in 0..<mainOptions.count{
                if mainOptions[i].button?.backgroundColor == UIColor.green{
                    ansIndex = i
                }
            }
        }
        if ansIndex == -1 {
            return ansIndex
        }else{
        return getQuestionType().options[ansIndex].value
        }
    }
    
    func displayAnswer(){
        
        if getQuestionType().multiplicity == "single"{
        for thing in currParams {
            if thing.key == "response_\(questionArray[index].id)"{
                let response = thing.value
                for i in 0..<getQuestionType().options.count{
                    if getQuestionType().options[i].value == response {
                        mainOptions[i].button?.backgroundColor = UIColor.green
                    }
                }
            }
        }
        }
        
    }
    
    func getQuestionType() -> questTypes{
        let currentType = questionArray[index].type
        var questType = masterQuestion.questionTypes[0]
        for quest in masterQuestion.questionTypes{
            if quest.id == currentType{
                questType = quest
            }
        }
        return questType
        
    }
    
    @objc func isSelected(sender: UIButton) {
       
        
        let questType = getQuestionType()
        if questType.multiplicity == "single"{
            
        if sender.backgroundColor == UIColor.green{
            sender.backgroundColor = UIColor.blue
        }else{
            for opt in mainOptions{
                opt.button?.backgroundColor = UIColor.blue
            }
            sender.backgroundColor = UIColor.green
        }
            
        }
    }

    
    @objc func submit(sender: UIBarButtonItem){
        submitQuestion()
    }

    
    @objc func back(sender: UIBarButtonItem){
       
        if index > 0 {
            if getAnswer() == -1{
                self.navigationController?.popViewController(animated: true)
            }else{
            currParams["response_\(questionArray[index].id)"] = getAnswer()
            self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func printParams(sender: UIButton){
        print(currParams)
    }
    
    @objc func next(sender:UIBarButtonItem) {
        if index < questionArray.count - 1{
            let nextQuestion = questionView()
            nextQuestion.index = self.index + 1
            nextQuestion.questionArray = self.questionArray
            nextQuestion.masterQuestion = self.masterQuestion
            nextQuestion.pqid = self.pqid
            
            if getAnswer() != -1{
                 currParams["response_\(questionArray[index].id)"] = getAnswer()
            }
           
            self.navigationController?.pushViewController(nextQuestion, animated: true)
            //submitQuestion()
        }
        
    }
    
    
    
}
