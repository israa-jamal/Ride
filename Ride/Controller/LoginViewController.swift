//
//  LoginViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/8/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
   
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ConfigureUI()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailTextfield.text else {return}
        guard let password = passwordTextfield.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Sorry there was an error signing you in \(error.localizedDescription)")
                return
            }
            print("successfully signed in")
            self.dismiss(animated: true, completion: nil)
        }
    }
//    func ConfigureUI(){
//        emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white ])
//        button.layer.cornerRadius = 5
//        navigationController?.navigationBar.barStyle = .black
//
//    }
    
}
