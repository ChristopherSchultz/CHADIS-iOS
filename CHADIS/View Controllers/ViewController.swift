//
//  ViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/4/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import UIKit
import WebKit
import LocalAuthentication

var baseURLString = UserDefaults.standard.string(forKey: "baseURL")


/* View controller class that controls the login screen and all of its various functions */
class ViewController: UIViewController {
    
    var loginSuccess = false //determines whether the login was successful
    var sessionID = "" //current session ID used to communicate with the server when using web view
    var session = URLSession.shared
    //var session : URLSession! //URLSession used to maintain same cookies when making subsequent request
    var lang = NSLocale.preferredLanguages[0] //current user's language preferences
    @IBOutlet weak var username: UITextField! //these are the fields and switch that the user interacts with
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var savePass: UISwitch!
    @IBOutlet weak var loginFailed: UILabel!
    @IBOutlet weak var loggingIn: UIActivityIndicatorView!
    
    @IBAction func test(_ sender: Any) {
        loggingIn.startAnimating()
    }
    
    
   
    
    
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
        loginFailed.isHidden = true
        if baseURLString == nil {
            UserDefaults.standard.set("https://dev.chadis.com/cscults-chaids/", forKey: "baseURL")
            baseURLString = UserDefaults.standard.string(forKey: "baseURL")
        }
        self.navigationController?.navigationBar.tintColor = UIColor.white
        if UserDefaults.standard.bool(forKey: "savePass") {
            savePass.setOn(true, animated: false)
            password.text = UserDefaults.standard.string(forKey: "savedPass")
            username.text = UserDefaults.standard.string(forKey: "savedUser")
        }
        if UserDefaults.standard.bool(forKey: "UseTouch") && UserDefaults.standard.bool(forKey: "savePass"){
         self.authenticationWithTouchID()
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
        
        print("credentials saved")
        if self.loginSuccess {
            loginFailed.isHidden = true
            self.performSegue(withIdentifier: "login", sender: self)
            if savePass.isOn {
                UserDefaults.standard.set(password.text, forKey: "savedPass")
                UserDefaults.standard.set(username.text, forKey: "savedUser")
                UserDefaults.standard.set(true, forKey: "savePass")
                
            }else{
                UserDefaults.standard.set(false, forKey: "savePass")
            }
            
        }else{
            loginFailed.isHidden = false
        }
        
        
    }
    
    func doLogin(){
        self.login(self)
    }
    
    

}


//extension that allows the home page to ask for authentification
extension ViewController {
    
    //function that asks user for touch ID
    func authenticationWithTouchID() {
        let context = LAContext()
        
        var error: NSError?
        
        //determines whether the device even has biometric scanners
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access requires Authentication", reply: {(success,errormes) in
                DispatchQueue.main.async {
                    
                    //On success this function section will execute
                    if success {
                        self.login(self)
                        self.notifyUser("Authentication Successful", err: "You have been succesfully logged in")
                    }
                    
                    //these are the error messages in case biometric authentication is unsuccessful
                    if let err = error {
                        
                        switch err._code {
                            
                        case LAError.Code.systemCancel.rawValue:
                            self.notifyUser("Session cancelled",
                                            err: err.localizedDescription)
                            
                        case LAError.Code.userCancel.rawValue:
                            self.notifyUser("Please try again",
                                            err: err.localizedDescription)
                            
                        case LAError.Code.userFallback.rawValue:
                            self.notifyUser("Authentication",
                                            err: "Password option selected")
                            // Custom code to obtain password here
                            
                        default:
                            self.notifyUser("Authentication failed",
                                            err: err.localizedDescription)
                        }
                        
                    }
                }
                
            }) } else {
            
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code {
                    
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser("User is not enrolled",
                               err: err.localizedDescription)
                    
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser("A passcode has not been set",
                               err: err.localizedDescription)
                    
                    
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser("Biometric authentication not available",
                               err: err.localizedDescription)
                default:
                    notifyUser("Unknown error",
                               err: err.localizedDescription)
                }
            }
        }
    }
    
    //custom function in order to handle successes, simply displays an alert that indicates
    //that authentication was successful
    public func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg,
                                      message: err,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true,
                     completion: nil)
    }
}

