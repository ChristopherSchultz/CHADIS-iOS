//
//  ViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/4/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import UIKit
import WebKit



class ViewController: UIViewController {
    
    var loginSuccess = false
    var sessionID = ""
    var session : URLSession!
    var lang = NSLocale.preferredLanguages[0]
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var savePass: UISwitch!
    
    @IBAction func switchChanged(_ sender: Any) {
        if savePass.isOn == false {
            UserDefaults.standard.set(false, forKey: "savePass")
        }else{
            UserDefaults.standard.set(true, forKey: "savePass")
        }
    }
    
    
    @IBAction func login(_ sender: Any) {
        session = URLSession(configuration: URLSessionConfiguration.default)
        loginSuccess = false
        let name = username.text!
        let pass = password.text!
        let sem = DispatchSemaphore(value: 0)
        let parameters = ["username": name, "password": pass]
        let loginURL = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/login.do")
        var request = URLRequest(url: loginURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    print("LOGIN success")
                    if let id = json["session"] as? NSDictionary {
                        self.sessionID = id["id"] as! String
                    }
                    self.loginSuccess = true
                } catch {
                    print("ERROR : ")
                    print(error)
                }
                sem.signal()
            }
        }.resume()
        sem.wait()
        if self.loginSuccess {
            self.performSegue(withIdentifier: "login", sender: self)
            if savePass.isOn {
                UserDefaults.standard.set(password.text, forKey: "savedPass")
                UserDefaults.standard.set(username.text, forKey: "savedUser")
                UserDefaults.standard.set(true, forKey: "savePass")
                
            }else{
                UserDefaults.standard.set(false, forKey: "savePass")
            }
           
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
        let dest = segue.destination as! patientViewController
        dest.sessionID = self.sessionID
        dest.session = self.session
        dest.username = self.username.text
        dest.pass = self.password.text
        }
        
        if segue.identifier == "noLogin" {
            let dest = segue.destination as! webViewController
            dest.loggedIn = false
            dest.urlString = "https://dev.chadis.com/cschultz-chadis"
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        if UserDefaults.standard.bool(forKey: "savePass") {
            savePass.setOn(true, animated: false)
            password.text = UserDefaults.standard.string(forKey: "savedPass")
            username.text = UserDefaults.standard.string(forKey: "savedUser")
        }
        
        
        
        print("USER'S PREFERRED LANGUAGE: \(self.lang)")
        // Do any additional setup after loading the view, typically from a nib.
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if savePass.isOn == false {
            UserDefaults.standard.set(false, forKey: "savedPass")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if savePass.isOn == false {
            username.text = ""
            password.text = ""
            
        }
    }
    
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

