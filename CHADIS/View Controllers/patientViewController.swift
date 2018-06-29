//
//  patientViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/5/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

/* Ths following are structs used to store the patients using the decodable protocol
 This allows the JSON to be parsed automatically into given structs that share the same parameters
 as the JSON */
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

/* This view controller is responsible for displaying all of the patients of a given respondent
It does this by retrieving the information from the server. */
class patientViewController: UITableViewController {
    
    
    var sessionID: String!
    var session = URLSession()
    var masterPatientList: PatientList? //This is the patient list that will ultimately be displayed
    let sem = DispatchSemaphore.init(value: 0)
    var username: String!
    var pass: String!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPatients = [Patient]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Patient Search", comment: "Searchbar placeholder")
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //The following is simply setup that I do to ensure the look of the app is consistent, I also
        // modify the navigation bar so that the functionality suits my purposes
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Patients"
        self.navigationItem.hidesBackButton = true
        
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("Logout", comment: "logout button"), style: UIBarButtonItemStyle.plain,
                                            target: self, action: #selector(patientViewController.back(sender:)))
        let newWebButton = UIBarButtonItem(title: "Web CHADIS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(patientViewController.web(sender:)))
        newWebButton.image = UIImage(named: "webIcon.png")
        self.navigationItem.rightBarButtonItem = newWebButton
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //Here is the URL Request and all of the parameters.
        //Note: I do not have to set cookies since the session was passed in from the previous view controller
        //allowing me to retrieve the patient list without having to pass in additional parameters
        let url = URL(string: baseURLString! + "respondent/api/patients.do")
        let request = URLRequest(url: url!)
        session.dataTask(with: request) { ( data, response, error) in
            
            if let data = data {
                do {
                  
                   // let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodePatient = try JSONDecoder().decode(PatientList.self, from: data)
                 //  print("Patients: \(decodePatient)")
                    
                    //this line gets the patient array and puts it into a local variable
                    self.masterPatientList = decodePatient
                    
                } catch {
                    print(error)
                }
                self.sem.signal()
            }
          
        }.resume()
        sem.wait()
        
        
    
    }
    
    //This function occurs whenever the back/logout button is pressed and invalidates and cancels the
    // URL Session allowing the user to safely logout and log back in
    @objc func back(sender: UIBarButtonItem){
        print(session)
        session.invalidateAndCancel()
        _ = navigationController?.popViewController(animated: true)
    }
    
    //this function simply sends the user to the webview page with the session ID embedded into the URL
    @objc func web(sender: UIBarButtonItem){

        performSegue(withIdentifier: "loggedIn", sender: self)
        
    }
    
    //this function determines how many cells to display which is simply the number of patients
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPatients.count
        }else{
        return (masterPatientList?.patients.count)!
        }
        
    }
    
    //This function determines what each cell will display. Currently it displays the patient's first and last name
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientCell
        let patient: Patient
        if isFiltering() {
            patient = filteredPatients[indexPath.row]
        }else{
            patient = (masterPatientList?.patients[indexPath.row])!
    }
        cell.patientName.text = "\((patient.last)), \((patient.first))"
        return cell
    }
    
    
    //These segues pass on desired information into the following view controllers.
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
            dest.urlString = baseURLString! + "staff/home.do;jsessionid=\((self.sessionID)!)?)"
            
        }
        
    }
    
    //this function is designed to ping the server and receive a response. As of right now, it has no use
    // but it could prove to be useful at a later date.
    func ping() {
        let pingUrl = URL(string: baseURLString! + "respondent/api/ping.do")
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
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPatients = masterPatientList!.patients.filter({( patient : Patient) -> Bool in
            let fullname = patient.first + patient.last
            return fullname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension patientViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
