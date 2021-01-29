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
    
    //MARK: Outlets

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var userTypeSegment: UISegmentedControl!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboardWhenTappedAround()

    }
   
    //MARK: Setup UI

    private func configureUI() {
        signUpButton.layer.cornerRadius = 5
        emailText.addPlaceHolder(text: "Email", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5))
        usernameText.addPlaceHolder(text: "Full Name", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5))
        passwordText.addPlaceHolder(text: "Password", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5))
        userTypeSegment.setTitleTextAttributes([.foregroundColor: UIColor(named: "alphaWhite") ?? UIColor.white], for: .normal)
        userTypeSegment.setTitleTextAttributes([.foregroundColor: UIColor(named: "Background") ?? UIColor.black], for: .selected)
        passwordText.textContentType = .telephoneNumber

    }
    
    //MARK: Actions

    @IBAction func signUpButton(_ sender: UIButton) {
        
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        guard let username = usernameText.text else {return}
        let userType = userTypeSegment.selectedSegmentIndex
        signUp(email: email, password: password, userName: username, userType: userType)
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Logic

    private func signUp(email : String, password: String, userName: String, userType: Int) {
        
        //create a new user in firebase
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                Helpers.alert(title: "There was an error registering your account", message: error.localizedDescription)
                return
            }
            guard let uid = result?.user.uid else {return}
            let values = ["email": email, "fullName": userName, "accountType": userType] as [String : Any]
            
            //add the new user in firebase database
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                if let error = error {
                    Helpers.alert(title: "Error", message: error.localizedDescription)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
