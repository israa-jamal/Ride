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
    
    //MARK: Outlets
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextfield: UITextField!
    
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
        ConfigureUI()
    }
    
    //MARK: Setup UI

    func ConfigureUI(){
        signInButton.layer.cornerRadius = 5
        emailTextfield.addPlaceHolder(text: "Email")
        passwordTextfield.addPlaceHolder(text: "Password")
    }
   
    //MARK: Actions

    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailTextfield.text else {return}
        guard let password = passwordTextfield.text else {return}
        signIn(email: email, password: password)
    }
    
    //MARK: Logic

    private func signIn(email : String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                Helpers.alert(title: "There was an error signing you in", message: error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
