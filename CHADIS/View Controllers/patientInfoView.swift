//
//  patientInfoView.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/8/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

//these structs are used to decode the JSON information and parse the data
struct quest: Decodable {
    var id: Int
    var status_id: Int
    var questionnaire_id: Int
    var dynamic: Bool
    var name: String
    var name_lang: String
    var assigned: String
    var assignor: String
}


struct questJson: Decodable {
    var patient: Patient
    var questionnaires: [quest]
}

/* This class/view controller is used to display patient information as well as the questionnaires
 assigned to the patient which will then allow the user to select and view the various
 questionnaires */
class patientInfoView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var DOB: UILabel!
    var patient: Patient?
    @IBOutlet weak var questTable: UITableView!
    var session = URLSession()
    var questList = [quest]()
    var sessionid: String!
    var searchController = UISearchController(searchResultsController: nil)
    var filteredQuest = [quest]()
    
    //these four arrays are used to divide the questionnaires into sections
    var newQuest = [quest]()
    var progressQuest = [quest]()
    var readyQuest = [quest]()
    var submitQuest = [quest]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questTable.delegate = self
        questTable.dataSource = self
       
        
        //same lines of code used to instantiate the search bar
       searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search Quests", comment: "searchbar placeholder quests")
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //data about the patient used to display information
        patientName.text = "\((patient?.last)!), \((patient?.first)!)"
        DOB.text = "DOB: \((patient?.dob)!)"
        
        
        //Classic URL request in order to retrieve the questionnaire information
        let sem = DispatchSemaphore(value: 0)
        let id = "?id=\((patient?.id)!)"
        let url = URL(string: baseURLString! + "respondent/api/patient/questionnaires.do" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)

                    self.questList = decodeQuest.questionnaires
                    self.sortQuest(quests: self.questList)
                   
                    sem.signal()
                } catch {
                    print(error)
                }
            }
        }.resume()
        sem.wait()
        questTable.rowHeight = UITableViewAutomaticDimension
        questTable.estimatedRowHeight = 200
        questTable.reloadData()
       
    
      
    }
    
    
    //this function serves only to refresh the page assuming that the user has filled out
    //a questionnaire thereby necessitating a refresh of the questinnaires
    //NOTE: Can probably compartamentalize all of this code into a separate function (TO DO)
    override func viewWillAppear(_ animated: Bool) {
    
        let sem = DispatchSemaphore(value: 0)
        let id = "?id=\((patient?.id)!)"
        let url = URL(string: baseURLString! + "respondent/api/patient/questionnaires.do" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)
                    self.questList = decodeQuest.questionnaires
                    sem.signal()
                } catch {
                    print(error)
                }
            }
            }.resume()
        sem.wait()
        questTable.reloadData()
        
    }
    
    //TABLE VIEW FUNCTIONS
    
    //returns the amount of rows per section, simply accessses the appropriate array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch section{
        case 0:
            return newQuest.count
        case 1:
            return progressQuest.count
        case 2:
            return readyQuest.count
        case 3:
            return submitQuest.count
        default:
            return newQuest.count
        }
    
    }
    
    //retrieves the appropriate data for each cell, also very simple
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questCell", for: indexPath) as! questCell
        let quest: quest!
        
    
        switch indexPath.section {
        case 0:
            quest = newQuest[indexPath.row]
        case 1:
            quest = progressQuest[indexPath.row]
        case 2:
            quest = readyQuest[indexPath.row]
        case 3:
            quest = submitQuest[indexPath.row]
        default:
            quest = newQuest[indexPath.row]
        }
        
        
        
        cell.questName.text = quest.name
        cell.status.text = String(quest.status_id)
        
        return cell
    }
    
    
    //returns the number of sections in the table total, currently returns 4 regardless of how many are
    //in each section
    func numberOfSections(in tableView: UITableView) -> Int {

        return 4

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "questHeaderCell") as! QuestHeaderCell
    
        headerCell.backgroundColor = UIColor.darkGray
        switch section {
        case 0:
            headerCell.questHeader.text = "New"
        case 1:
            headerCell.questHeader.text = "In Progress"
        case 2:
            headerCell.questHeader.text = "Ready to Submit"
        case 3:
            headerCell.questHeader.text = "Submitted"
        default:
            headerCell.questHeader.text = "Unexpected"
        }

        return headerCell
    
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            
            var quest: quest?
            guard let indexPath = questTable.indexPathForSelectedRow else {
                print("error in row selection")
                return
            }
            
            guard let section = questTable.indexPathForSelectedRow?.section else{
                print("error in section selection")
                return
            }
            
            switch section {
            case 0:
                quest = newQuest[indexPath.row]
            case 1:
                quest = progressQuest[indexPath.row]
            case 2:
                quest = readyQuest[indexPath.row]
            case 3:
                quest = submitQuest[indexPath.row]
            default:
                quest = newQuest[indexPath.row]
            }
            let dest = segue.destination as! optionsController
            dest.status = quest?.status_id
            switch quest?.status_id {
            case 1,4,7,8:
                dest.numCells = 1
            case 2,3:
                dest.numCells = 3
            default:
                dest.numCells = 0
                print("error with Status")
                
            }
            dest.quest = quest
            dest.isDynamic = quest?.dynamic
            dest.patient = self.patient
            dest.sessionid = self.sessionid
            dest.pqid = quest?.id
            
        }
    }
    
    //SEARCH BAR FUNCTIONS AND HELPERS
  
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredQuest = questList.filter({( quest : quest) -> Bool in
            let fullname = quest.name
            return fullname.lowercased().contains(searchText.lowercased())
        })
        
        if searchText == "" {
            sortQuest(quests: self.questList)
        }else{
        sortQuest(quests: filteredQuest)
        }
        questTable.reloadData()
    }
    
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
    func sortQuest(quests: [quest]) {
        
        clearQuests()
        for quest in quests {
            switch quest.status_id {
            case 1:
                newQuest.append(quest)
            case 2:
                progressQuest.append(quest)
            case 3:
                readyQuest.append(quest)
            case 4:
                submitQuest.append(quest)
            default:
                newQuest.append(quest)
            }
        }
        
    }
    
    func clearQuests(){
        newQuest.removeAll()
        progressQuest.removeAll()
        readyQuest.removeAll()
        submitQuest.removeAll()
    }
    
    
    func testQuest(pqid:Int){
        
    }
    
    
   
    
  
    
    
}

extension patientInfoView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
filterContentForSearchText(searchController.searchBar.text!)
    }
}

