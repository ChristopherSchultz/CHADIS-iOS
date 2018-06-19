//
//  optionsController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/12/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

class optionsController: UICollectionViewController {

    
    var status: Int!
    var pqid: Int!
    var numCells: Int!
    var options: [String]!
    var sessionid: String!
    var begin = NSLocalizedString("begin", comment: "begin option")
    var cont = NSLocalizedString("continue", comment: "continue option")
    var review =  NSLocalizedString("review", comment: "review option")
    var restart = NSLocalizedString("restart", comment: "restart option")
    var sub = NSLocalizedString("submit", comment: "submit option")
   
    override func viewDidLoad() {
        
        switch status{
        case 1:
            options = [begin]
        case 2:
            options = [cont,review,restart]
        case 3:
            options = [review,sub,restart]
        case 4,7,8:
            options = [review]
        default:
            options = ["Error, Please Try Again"]
        }
        super.viewDidLoad()
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numCells
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as! optionCell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.optionLabel.text = options[indexPath.row]
        

        return cell
    }
    
    
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuest" {
            let dest = segue.destination as! QuestWebView
            dest.pqid = self.pqid
            dest.status = self.status
            dest.sessionid = self.sessionid
        }
    }
}
