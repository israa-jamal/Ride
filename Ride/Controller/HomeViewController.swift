//
//  HomeViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/12/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class HomeViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
//       map.isHidden = true
// signOut()
        checkIfUserIsLogedIn()
        // Do any additional setup after loading the view.
    }
    
    
    func checkIfUserIsLogedIn(){
       if Auth.auth().currentUser?.uid == nil{
        DispatchQueue.main.async {
           
           self.performSegue(withIdentifier: "goToLogin", sender: self)
              
//            self.view.window?.rootViewController = LoginViewController()
//            self.view.window?.makeKeyAndVisible()

//             self.present(navigationController, animated: true, completion: nil)
        }
        print("debug: the user is signed out")
        }
       else{
        map.isHidden = false
        }
    }
    
    func signOut(){
        do{
            print("the user is signed out")
         try Auth.auth().signOut()
        }
    catch{
        print(error)
        }
    }

}
