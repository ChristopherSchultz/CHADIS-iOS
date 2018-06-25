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
    @IBOutlet weak var baseURL: UITextField!
    
    @IBOutlet weak var touchSwitch: UISwitch!
    
    @IBAction func touchChanged(_ sender: Any) {
        if touchSwitch.isOn {
        UserDefaults.standard.set(true, forKey: "UseTouch")
        }else{
            UserDefaults.standard.set(false, forKey: "UseTouch")
        }
        
    }
    
    @IBAction func urlChanged(_ sender: Any) {
        UserDefaults.standard.set(baseURL.text, forKey: "baseURL")
        baseURLString = baseURL.text
    }

    
    
    override func viewDidLoad() {
        
        if UserDefaults.standard.bool(forKey: "UseTouch"){
            touchSwitch.setOn(true, animated: true)
        }else{
            touchSwitch.setOn(false, animated: true
            )
        }
        if UserDefaults.standard.string(forKey: "baseURL") == nil {
            UserDefaults.standard.set("https://dev.chadis.com/cschultz-chadis/", forKey: "baseURL")
        }
        baseURL.text = UserDefaults.standard.string(forKey: "baseURL")
        if UserDefaults.standard.value(forKey: "language") == nil {
            UserDefaults.standard.set("English", forKey: "language")
        }
        
    
        super.viewDidLoad()
        self.title = "Settings"
        
    }
    
    
}
