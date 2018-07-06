//
//  questionView.swift
//  CHADIS
//
//  Created by Paxon Yu on 7/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit


class questionView: UIViewController {
    
    var index: Int!
    var questionArray: [questions]!
    var questionText: String?
    var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        return label
    }()
    
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
        
        
        
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(questionView.next(sender:)))
        self.navigationItem.rightBarButtonItem = nextButton
        
        
        
    }
    

    
    @objc func next(sender:UIBarButtonItem) {
        if index < questionArray.count - 1{
            let nextQuestion = questionView()
            nextQuestion.index = self.index + 1
            nextQuestion.questionArray = self.questionArray
            self.navigationController?.pushViewController(nextQuestion, animated: true)
        }
        
    }
    
    
    
}
