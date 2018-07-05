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
    
    var questionText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Question"
        self.view.backgroundColor = UIColor.white
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.center = self.view.center
        label.text = "What up"
        self.view.addSubview(label)
        
        
    }
    
    
}
