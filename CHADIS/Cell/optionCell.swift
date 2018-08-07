//
//  optionCell.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/12/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation


import UIKit

class optionCell: UICollectionViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    
    
    

    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
              
                self.contentView.backgroundColor = UIColor.lightGray
                
            }
            else
            {
                
                self.contentView.backgroundColor = UIColor.white
            }
        }
    }
    
}
