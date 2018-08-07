//
//  BounceButton.swift
//  CHADIS
//
//  Created by Paxon Yu on 7/31/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import UIKit

//the whole purpose of this class is to create a button that bounces a bit, adds a bit of flair to the whole
//app
class BounceButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
            }, completion: nil)
        super.touchesBegan(touches, with: event)
        
    }
}
