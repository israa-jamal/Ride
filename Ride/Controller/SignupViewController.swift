//
//  SignupViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/10/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var userTypeSegment: UISegmentedControl!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpButton(_ sender: UIButton) {
    }
    
    
    @IBAction func signinButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
