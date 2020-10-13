//
//  SignupViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/10/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import Firebase

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
        
        //while email, password and username aren't nil
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        guard let username = usernameText.text else {return}
        let userType = userTypeSegment.selectedSegmentIndex
        
        //debug
        print(email)
        print(password)
        //create a new user in firebase
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("There was an error registering your account\(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else {return}
            let values = ["email": email, "username": username, "accountType": userType] as [String : Any]
            //add the new user in firebase database
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                       print("successfully registered")
                
                //dismiss view once the account is registered
                self.dismiss(animated: true, completion: nil)
        }
        }
    }
    
    @IBAction func signinButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
