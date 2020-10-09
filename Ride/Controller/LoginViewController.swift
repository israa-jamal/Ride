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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBAction func loginButton(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureUI()
        
        // Do any additional setup after loading the view.
    }
    func ConfigureUI(){
        emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white ])
        button.layer.cornerRadius = 5
        navigationController?.navigationBar.barStyle = .black

    }
    
}
