//
//  patientInfoView.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/8/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

struct quest: Decodable {
    var id: Int
    var status_id: Int
    var questionnaire_id: Int
    var name: String
    var name_lang: String
    var assigned: String
    var assignor: String
}


struct questJson: Decodable {
    var patient: Patient
    var questionnaires: [quest]
}

class patientInfoView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var DOB: UILabel!
    var patient: Patient?
    @IBOutlet weak var questTable: UITableView!
    var session = URLSession()
    var questList = [quest]()
    var sessionid: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questTable.delegate = self
        questTable.dataSource = self
        
        
        patientName.text = "\((patient?.last)!), \((patient?.first)!)"
        DOB.text = "DOB: \((patient?.dob)!)"
        let sem = DispatchSemaphore(value: 0)
        let id = "?id=\((patient?.id)!)"
        let url = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/patient/questionnaires.do" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)
                    print(decodeQuest)
                    self.questList = decodeQuest.questionnaires
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
    
    override func viewWillAppear(_ animated: Bool) {
    
        
        print("I GET RUN")
        patientName.text = "\((patient?.last)!), \((patient?.first)!)"
        DOB.text = "DOB: \((patient?.dob)!)"
        let sem = DispatchSemaphore(value: 0)
        let id = "?id=\((patient?.id)!)"
        let url = URL(string: "https://dev.chadis.com/cschultz-chadis/respondent/api/patient/questionnaires.do" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        session.dataTask(with: request) { (data,response,error) in
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    let decodeQuest = try JSONDecoder().decode(questJson.self, from: data)
                    print(decodeQuest)
                    self.questList = decodeQuest.questionnaires
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questCell", for: indexPath) as! questCell
        let quest = questList[indexPath.row]
        cell.questName.text = quest.name
        cell.status.text = String(quest.status_id)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            guard let indexPath = questTable.indexPathForSelectedRow else{
                print("error in selecting quest")
                return
            }
            let quest = questList[indexPath.row]
            let dest = segue.destination as! optionsController
            dest.status = quest.status_id
            switch quest.status_id {
            case 1,4,7,8:
                dest.numCells = 1
            case 2,3:
                dest.numCells = 3
            default:
                dest.numCells = 0
                print("error with Status")
                
            }
            dest.sessionid = self.sessionid
            dest.pqid = quest.id
        }
    }
  
    
}
