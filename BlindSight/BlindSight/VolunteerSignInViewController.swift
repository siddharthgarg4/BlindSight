//
//  VolunteerAuthViewController.swift
//  BlindSight
//
//  Created by Pranav Panchal on 2019-05-04.
//  Copyright © 2019 Siddharth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class VolunteerSignInViewController: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        guard let email = emailInput.text, let password = passwordInput.text else {
            return
        }
        
        loginUser(withEmail: email, password: password)
        
        self.performSegue(withIdentifier: "VolunteerViewSegue2", sender: self)
        
//        if Auth.auth().currentUser != nil {
//                self.performSegue(withIdentifier: "VolunteerViewSegue2", sender: self)
//        } else {
//            //error
//        }
    }
    
    func loginUser(withEmail email:String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeleft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        self.hideKeyboardWhenTappedAround() 
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func swipeleft() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
