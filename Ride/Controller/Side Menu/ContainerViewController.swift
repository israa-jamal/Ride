//
//  ContainerViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 05/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit
import Firebase

class ContainerViewController: UIViewController {
    
    private var homeViewController : HomeViewController!
    private var menuViewController : MenuViewController!
    
    private var user : User? {
        didSet{
            guard let user = user else {return}
            self.initiateHomeController(withUser: user)
            self.initiateMenuController(withUser: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData()
    }
    
    //MARK:- API
    
    func getUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: uid) { user in
            self.user = user
        }
    }
    
    func logOut() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            API.signOut {
                self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthNavigation")
                self.view.window?.makeKeyAndVisible()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Helpers
    
    func initiateHomeController(withUser user : User) {
        homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigation") as? HomeViewController ?? HomeViewController()
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        homeViewController.delegate = self
        homeViewController.user = user
    }
    
    func initiateMenuController(withUser user : User) {
        menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuController") as? MenuViewController ?? MenuViewController()
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        view.insertSubview(menuViewController.view, at: 0)
        menuViewController.user = user
        menuViewController.delegate = self
    }
    func routeToSettings() {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsController") as? SettingsViewController ?? SettingsViewController()
        let nav = UINavigationController(rootViewController: VC)
        nav.modalPresentationStyle = .fullScreen
        VC.user = user
        self.present(nav, animated: true, completion: nil)
    }
//    func routeToSettings() {
//        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsController") as? SettingsViewController ?? SettingsViewController()
//        let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigation") as? UINavigationController ?? UINavigationController()
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true, completion: nil)
//    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}

//MARK:- HomeViewControllerDelegate

extension ContainerViewController : HomeViewControllerDelegate {
 
    func handleMenuSliding(shouldSlide: Bool) {
        animateMenu(shouldSlide)
    }
    
    func animateMenu(_ shouldSlide: Bool, completion: ((Bool)->(Void))? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if shouldSlide {
                self.homeViewController.view.frame.origin.x = self.view.frame.width - 80
            } else {
                self.homeViewController.view.frame.origin.x = 0
            }
        }, completion: completion)
        animateStatusBar()
    }
}

//MARK:- MenuControllerDelegate

extension ContainerViewController: MenuControllerDelegate {
    
    func didSelect(option: MenuOptions) {
        switch option {
        case .yourTrips:
            print("Show Your Trips")
        case .settings:
            routeToSettings()
        case .logout:
            animateMenu(false) {_ in 
                self.homeViewController.isMenuOpen = false
                self.logOut()
            }
        }
    }
}
/*
 
 */
