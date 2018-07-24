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
    
    //this label will be the main question label
    var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.baselineAdjustment = .none
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    var mainOptions = [questionOptions]()
    var pqid: Int!
    var progressBar: UIProgressView!
    var answerScroll: UIScrollView!
    var questScroll: UIScrollView!
    var error: UILabel?
    var toolBar: UIToolbar!
 
    
    
    override func viewDidLoad() {
        
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 75, width: self.view.frame.width, height: 20))
        progressBar.center.x = self.view.center.x
        progressBar.setProgress(Float(index)/Float(questionArray.count), animated: true)
        progressBar.progressTintColor = UIColor.green
        self.view.addSubview(progressBar)
        
        super.viewDidLoad()
        //determines all of the upper level information that will want to be displayed
        self.navigationItem.title = "Question \(index + 1)"
        self.view.backgroundColor = UIColor.white
       
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(questionView.doneButtonAction(sender:)))
        toolBar.setItems([flexSpace,doneBtn], animated: false)
        toolBar.sizeToFit()

       
        
        label.text = questionArray[index].text
        if (label.text?.count)! > 200 {
           // print("greater than")
            var scroll = UIScrollView()
            self.view.addSubview(scroll)
            scroll.contentSize = CGSize(width: self.view.frame.width, height: CGFloat((label.text?.count)! / 50) * 70)
            scroll.translatesAutoresizingMaskIntoConstraints = false
            scroll.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -345).isActive = true
            scroll.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
            scroll.backgroundColor = UIColor.purple
            scroll.addSubview(label)
            label.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 20).isActive = true
            questScroll = scroll
            self.view.bringSubview(toFront: progressBar)
        }else{
             self.view.addSubview(label)
            
          
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
           
        }
        
        label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.sizeToFit()
        
       
        generateOptions()
        displayAnswer()
        
        //This is a dummy button that currently displays the parameters up to the current point
        //maybe this will be used as a save and exit button
        var display = UIButton(frame: CGRect(x: 300, y: 200, width: 200, height: 50))
        display.addTarget(self, action: #selector(questionView.printParams(sender:)), for: UIControlEvents.touchUpInside)
        display.setTitle("Display", for: .normal)
        display.backgroundColor = UIColor.purple
        display.layer.cornerRadius = 5
        self.view.addSubview(display)
        display.translatesAutoresizingMaskIntoConstraints = false
        display.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        display.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        display.widthAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        
        //if the user has reached the end of all of the questions then provide a submit button instead
        if index != questionArray.count - 1{
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(questionView.next(sender:)))
            nextButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = nextButton
        
        }else{
            let submitButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(questionView.submit(sender:)))
            self.navigationItem.rightBarButtonItem = submitButton
            print(currParams)
            
        }
        
        //custom back button to pass in pertinent information
        if index > 0{
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(questionView.back(sender:)))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        
        
    }
    
    
    
    //function used to display all of the options on the screen given the question type
    func generateOptions() {
        let questionType = questionArray[index].type
        var indexOpt = 0
        var options = [option]()
        var questType: questTypes!
        var scrollView: UIScrollView = UIScrollView()
        for questT in masterQuestion.questionTypes{
            if questT.id == questionType {
                questType = questT
                options = questT.options
            }
        }
        answerScroll = scrollView
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 300)
        self.view.addSubview(scrollView)
        
        
        //if the number of options excede 4 then provide a scroll view so the user can view all of the options
        if options.count > 4 {
           
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: CGFloat(options.count * 105))
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.backgroundColor = UIColor.cyan
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        }else{
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.backgroundColor = UIColor.cyan
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300).isActive = true
            scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1, constant: 0).isActive = true
        
        }
        
        //for every option provided that it is either a button or a button with a textfield, generate it and
        //display said option
        for option in options {
            var opt = questionOptions()
            if option.freeResponseDataType  == nil && options.count <= 4 {
                let button: UIButton!
                button = UIButton(frame: CGRect(x: 25, y: 50 + indexOpt * 50, width: 150, height: 40))

               

           // button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.blue
            button.layer.cornerRadius = 10
            button.setTitle("\(option.text)", for: .normal)
            button.addTarget(self, action: #selector(questionView.isSelected(sender:)), for: UIControlEvents.touchUpInside)
            opt.button = button
            mainOptions.append(opt)
           
                
            scrollView.addSubview(button)
            view.addSubview(scrollView)
            indexOpt = indexOpt +  1
            }else if options.count > 4{
            
                let button: UIButton!
              
                    button = UIButton(frame: CGRect(x: 25, y: 50 + indexOpt * 50, width: 150, height: 40))
              
                    //button = UIButton(frame: CGRect(x: 25, y: 300 + indexOpt * 100, width: 150, height: 40))
                
                button.backgroundColor = UIColor.blue
                button.setTitle("\(option.text)", for: .normal)
                button.addTarget(self, action: #selector(questionView.isSelected(sender:)), for: UIControlEvents.touchUpInside)
                button.layer.cornerRadius = 10
                button.titleLabel?.numberOfLines = 0
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                opt.button = button
                mainOptions.append(opt)
                scrollView.addSubview(button)
                indexOpt = indexOpt + 1
            
            
            
            
            }else{ //code for a button and a textfield
                
                let button: UIButton!
                scrollView.contentSize.width = (scrollView.contentSize.width) + 20
                    button = UIButton(frame: CGRect(x: 25, y: 50 + indexOpt * 50, width: 150, height: 40))
               
                   // button = UIButton(frame: CGRect(x: 25, y: 300 + indexOpt * 100, width: 150, height: 40))
                
                button.backgroundColor = UIColor.blue
                button.setTitle("\(option.text)", for: .normal)
                button.addTarget(self, action: #selector(questionView.isSelected(sender:)), for: UIControlEvents.touchUpInside)
                button.layer.cornerRadius = 10
                button.titleLabel?.numberOfLines = 0
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                //button.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
                var text: UITextField! {
                    didSet{
                        print("I'm working")
                        if checkReady() {
                            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
                        }
                    }
                }
                      text = UITextField(frame: CGRect(x: Int(50 + button.frame.width), y: 50 + indexOpt * 50, width: 300, height: 40))
                    //text = UITextField(frame: CGRect(x: Int(50 + button.frame.width), y: 300 + indexOpt * 100, width: 300, height: 50))
                
                
                text.borderStyle = .roundedRect
                text.alpha = 0.7
                
                opt.button = button
                opt.text = text
                opt.text?.addTarget(self, action: #selector(questionView.textfieldDidChange(sender:)), for: UIControlEvents.editingChanged)
                text.inputAccessoryView = toolBar
                mainOptions.append(opt)
                scrollView.addSubview(button)
                scrollView.addSubview(text)
                  
             
                }
                indexOpt = indexOpt + 1
            }
            
        }

        
    
    
    //this function makes an API call and posts all of the parameters.
    //TO DO: Make this work
    func submitQuestion() {
        let url = URL(string: baseURLString! + "respondent/api/patient/questionnaire/answer-questions.do?id=\((pqid)!)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
       // let params = ["response_\(currQuest)": getAnswer()]
        updateParams()
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
    
    //this function will use the background color of each button to determine whether it has be selected or not
    //It will then determine what value the answer will be
    func getAnswer() -> Int{
        var ansIndex = -24
        if getQuestionType().multiplicity == "single"{
            for i in 0..<mainOptions.count{
                if mainOptions[i].button?.backgroundColor == UIColor.green{
                    ansIndex = i
                }
            }
        }
        if ansIndex == -24 {
            return ansIndex
        }else{
        return getQuestionType().options[ansIndex].value
        }
    }
    
    
    
    //This function is used to display what answers the user has previously chosen assuming that there exists
    //a previously chosen answer
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
    
    @objc func textfieldDidChange(sender: UITextField) {
        var useOpt: questionOptions?
        for opt in mainOptions{
            if opt.text == sender {
                useOpt = opt
            }
        }
        if getQuestionType().multiplicity == "single"{
            for opt in mainOptions{
                opt.button?.backgroundColor = UIColor.blue
            }
            useOpt?.button?.backgroundColor = UIColor.green
        }else if getQuestionType().multiplicity == "multiple"{
            useOpt?.button?.backgroundColor = UIColor.green
        }
        
        if sender.text == "" {
            useOpt?.button?.backgroundColor = UIColor.blue
        }
        if checkFreeText() {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        }else{
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
    }
    
    //This function will retrieve the question type of the current question in order to be able to decode
    //the answer
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
    
    //returns the selected option assuming that one has been selected
    func getSelectedOption() -> option {
        if getQuestionType().multiplicity == "single"{
            for i in 0..<mainOptions.count {
                if mainOptions[i].button?.backgroundColor == UIColor.green{
                    return getQuestionType().options[i]
                }
            }
        }
        return getQuestionType().options[0]
    }
    
    //Will simply change the background color of a selected button
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
            
        }else if questType.multiplicity == "multiple"{
            if sender.backgroundColor == UIColor.green{
            sender.backgroundColor = UIColor.blue
            }else{
                sender.backgroundColor = UIColor.green
            }
    }
        
        if checkReady(){
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        }else{
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
    }
    
    //Will update the current answers of the user's questionnaire
    func updateParams() {
        
        if getAnswer() != -24{
            currParams["response_\(questionArray[index].id)"] = getAnswer()
        }
        
    }
    
    func checkFreeText() -> Bool{
        for i in 0..<mainOptions.count{
            if mainOptions[i].button?.backgroundColor == UIColor.green && getSelectedOption().freeResponseRegexp != nil{
               print(getSelectedOption().freeResponseRegexp!)
                if mainOptions[i].text?.text?.range(of: getSelectedOption().freeResponseRegexp!, options: String.CompareOptions.regularExpression, range: nil, locale: nil) != nil {
                    return true
                }else{
                    return false
                }
                
                
            }
        }
        return false
    }
    
    //function that checks to see if the user has successfully answered based on the requirements of the question
    func checkReady() -> Bool{
        let type = getQuestionType()
        if type.multiplicity == "single" || type.multiplicity == "multiple"{
            for opt in mainOptions {
                if opt.button?.backgroundColor == UIColor.green && opt.text == nil {
                    return true
                }else if opt.button?.backgroundColor == UIColor.green && checkFreeText(){
                    return true
                }
            }
        }
        return false
    }

    
    //The following are completion handlers for buttons throughout the page. The name of each button should be
    // self explanatory
    
    
    @objc func doneButtonAction(sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
    
    
    @objc func submit(sender: UIBarButtonItem){
        submitQuestion()
    }

    
    @objc func back(sender: UIBarButtonItem){
       
        if index > 0 {
            if getAnswer() == -24{
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

            if checkReady(){
                print("we're good")
                if error != nil {
                    error?.removeFromSuperview()
                }
            }else{
                print("nah")
                let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
                if getSelectedOption().freeResponseErrorText != nil {
                errorLabel.text = getSelectedOption().freeResponseErrorText
                }else{
                    errorLabel.text = "Please enter a valid response"
                }
                view.addSubview(errorLabel)
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                errorLabel.textColor = UIColor.red
                errorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
               
                errorLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 320).isActive = true
                error = errorLabel
                return
            }
            
        
        
        if index < questionArray.count - 1{
            let nextQuestion = questionView()
            nextQuestion.index = self.index + 1
            nextQuestion.questionArray = self.questionArray
            nextQuestion.masterQuestion = self.masterQuestion
            nextQuestion.pqid = self.pqid
            
            if getAnswer() != -24{
                 currParams["response_\(questionArray[index].id)"] = getAnswer()
            }
           
            self.navigationController?.pushViewController(nextQuestion, animated: true)
            //submitQuestion()
        }
        
    }
    
    
    
}
