//
//  LoginViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/8/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
   
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBAction func loginButton(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeUI()
        
        // Do any additional setup after loading the view.
    }
    func changeUI(){
        emailTextfield.keyboardAppearance = .dark
        emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white ])
        button.layer.cornerRadius = 5

    }
    
}
