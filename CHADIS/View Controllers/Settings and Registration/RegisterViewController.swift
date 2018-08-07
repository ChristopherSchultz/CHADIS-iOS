//
//  RegisterViewController.swift
//  CHADIS
//
//  Created by Paxon Yu on 6/27/18.
//  Copyright © 2018 Paxon Yu. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var invitationCode: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePass: UITextField!
    @IBOutlet weak var question: UIPickerView!
    @IBOutlet weak var answer: UITextField!
    var qrCode: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register User"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIPasteboard.general.string != "" {
            invitationCode.text = UIPasteboard.general.string
        }
    }
}
