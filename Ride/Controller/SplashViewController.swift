//
//  SplashViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 17/02/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var initialView = UIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
//        API.signOut()
        checkIfTheUserLoggedIn()
    }
    
    func checkIfTheUserLoggedIn() {
        
        if API.isUserLoggedIn() {
            DispatchQueue.main.async {
                self.initialView = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") ?? HomeViewController()
                self.view.window?.rootViewController = self.initialView
                self.view.window?.makeKeyAndVisible()
            }
        } else {
            DispatchQueue.main.async {
                self.initialView = self.storyboard?.instantiateViewController(withIdentifier: "AuthNavigation") ?? LoginViewController()
                self.view.window?.rootViewController = self.initialView
                self.view.window?.makeKeyAndVisible()
            }
        }
        
    }
}
