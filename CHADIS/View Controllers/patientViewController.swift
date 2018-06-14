//
//  patientViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

struct PatientList: Decodable {
    var patients: [Patient]
}

struct Patient: Decodable {
    var id: Int
    var first: String
    var middle: String
    var last: String
    var dob: String
    
}


class patientViewController: UITableViewController {
    
    
    var sessionID = String()
    var session = URLSession()
    var masterPatientList: PatientList?
    let sem = DispatchSemaphore.init(value: 0)
    var username: String!
    var pass: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Patients"
        ping()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain,
                                            target: self, action: #selector(patientViewController.back(sender:)))
        let newWebButton = UIBarButtonItem(title: "Web CHADIS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(patientViewController.web(sender:)))
        newWebButton.image = UIImage(named: "webIcon.png")
        self.navigationItem.rightBarButtonItem = newWebButton
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //let url = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/ping.do")
        let url = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/patients.do")
        let request = URLRequest(url: url!)
        session.dataTask(with: request) { ( data, response, error) in
            
            if let data = data {
                do {
                  
                   // let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodePatient = try JSONDecoder().decode(PatientList.self, from: data)
                 //  print("Patients: \(decodePatient)")
                    self.masterPatientList = decodePatient
                    
                } catch {
                    print(error)
                }
                self.sem.signal()
            }
          
        }.resume()
        sem.wait()
        
            
        
        
    
    }
    
    @objc func back(sender: UIBarButtonItem){
        print(session)
        session.invalidateAndCancel()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func web(sender: UIBarButtonItem){

        performSegue(withIdentifier: "loggedIn", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (masterPatientList?.patients.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientCell
        let patient = masterPatientList?.patients[indexPath.row]
        cell.patientName.text = "\((patient?.last)!), \((patient?.first)!)"
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "patientInfo" {
            let dest = segue.destination as! patientInfoView
            guard let indexPath = tableView.indexPathForSelectedRow else {
                print("error with Row selection")
                return
            }
            let pat = masterPatientList?.patients[indexPath.row]
            dest.patient = pat
            dest.session = self.session
            dest.sessionid = self.sessionID
            
            
        }
        
        if segue.identifier == "loggedIn" {
            
            print(self.username)
            print(self.pass)
    
            let dest = segue.destination as! webViewController
            dest.loggedIn = true
            dest.username = self.username
            dest.password = self.pass
            dest.urlString = "https://dev.chadis.com/cschultz-chadis/staff/home.do;jsessionid=\(self.sessionID)?)"
            
        }
        
    }
    
    func ping() {
        let pingUrl = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/ping.do")
        let request = URLRequest(url: pingUrl!)
        session.dataTask(with: request){ ( data, response, error) in
            
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    print(json)
                 
                    
                } catch {
                    print(error)
                }
             
            }
            
            }.resume()
    }
    
}
