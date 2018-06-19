//
//  ViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/4/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import UIKit
import WebKit

var baseURLString = UserDefaults.standard.string(forKey: "baseURL")


/* View controller class that controls the login screen and all of its various functions */
class ViewController: UIViewController {
    
    var loginSuccess = false //determines whether the login was successful
    var sessionID = "" //current session ID used to communicate with the server when using web view
    var session : URLSession! //URLSession used to maintain same cookies when making subsequent request
    var lang = NSLocale.preferredLanguages[0] //current user's language preferences
    @IBOutlet weak var username: UITextField! //these are the fields and switch that the user interacts with
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var savePass: UISwitch!
    
    //function used to determine whether the switch has changed or not in order to determine whether to save
    //the user's credentials
    @IBAction func switchChanged(_ sender: Any) {
        if savePass.isOn == false {
            UserDefaults.standard.set(false, forKey: "savePass")
        }else{
            UserDefaults.standard.set(true, forKey: "savePass")
        }
    }
    
    //function that activates whenever the login button is pressed. Sends a request to the server to determine
    //validation.
    @IBAction func login(_ sender: Any) {
        
        //instantiates the URL Session and sets up all of the proper parameters
        session = URLSession(configuration: URLSessionConfiguration.default)
        loginSuccess = false
        let name = username.text!
        let pass = password.text!
        let sem = DispatchSemaphore(value: 0)
        let parameters = ["username": name, "password": pass]
        //let loginURL = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/login.do")
        let loginURL = URL(string: baseURLString! + "respondent/api/login.do")
        var request = URLRequest(url: loginURL!)
        
        //modifying the URL Request with the proper parameters
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        //requests the data
        session.dataTask(with: request) { (data, response, error) in
            
            //manipulating the data by converting it from a JSON to a Dictionary and then retrieving all of the
            //relevant information
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
        

        
        //use of semaphore so that all of the calculations regarding the pulled information gets completed
        //after the request returns the data
        sem.wait()
        saveCredentials()
        
   
    }
    
    //general function that gets called everytime a view controller is about to be switched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //if the segue is the login then pass in all of the relevant information to the following view controller
        if segue.identifier == "login" {
        let dest = segue.destination as! patientViewController
        dest.sessionID = self.sessionID
        dest.session = self.session
        dest.username = self.username.text
        dest.pass = self.password.text
        }
        
        //if the segue is to go to the webview, redirect the webview to the chadis website
        if segue.identifier == "noLogin" {
            let dest = segue.destination as! webViewController
            dest.loggedIn = false
            dest.urlString = baseURLString
        }
        
        
    }
    
    //function that is called every time the view controller is succesffully loaded
    //Note: the function is only called once since it is attached to a navigation bar
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
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "savePass") == false{
            username.text = ""
            password.text = ""
        }
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function that determines whether a login was successful and if it was
    //to save or not save user credentials
    func saveCredentials() {
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

}

