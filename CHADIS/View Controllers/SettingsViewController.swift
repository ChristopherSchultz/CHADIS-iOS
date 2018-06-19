//
//  SettingsViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/18/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var language: UISegmentedControl!
    @IBOutlet weak var baseURL: UITextField!
    
    @IBAction func urlChanged(_ sender: Any) {
        UserDefaults.standard.set(baseURL.text, forKey: "baseURL")
        baseURLString = baseURL.text
    }
    @IBAction func langChanged(_ sender: Any) {
        switch language.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set("English", forKey: "language")
        case 1:
            UserDefaults.standard.set("Spanish", forKey: "language")
        case 2:
              UserDefaults.standard.set("French", forKey: "language")
        case 3:
            UserDefaults.standard.set("Chinese", forKey: "language")
        case 4:
            UserDefaults.standard.set("Auto", forKey: "language")
        default:
            UserDefaults.standard.set("English", forKey: "language")
        }
    }
    
    
    override func viewDidLoad() {
        if UserDefaults.standard.string(forKey: "baseURL") == nil {
            UserDefaults.standard.set("https://dev.chadis.com/cschultz-chadis/", forKey: "baseURL")
        }
        baseURL.text = UserDefaults.standard.string(forKey: "baseURL")
        if UserDefaults.standard.value(forKey: "language") == nil {
            UserDefaults.standard.set("English", forKey: "language")
        }else{
            switch UserDefaults.standard.value(forKey: "language") as! String{
            case "English":
                language.selectedSegmentIndex = 0
            case "Spanish":
                language.selectedSegmentIndex = 1
            case "French":
                language.selectedSegmentIndex = 2
            case "Chinese":
                language.selectedSegmentIndex = 3
            case "Auto":
                language.selectedSegmentIndex = 4
            default:
                language.selectedSegmentIndex = 1
            }
        }
        super.viewDidLoad()
        self.title = "Settings"
        
    }
    
    
}
