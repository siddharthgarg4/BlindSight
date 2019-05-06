//
//  VolunteerSignUpViewController.swift
//  BlindSight
//
//  Created by Pranav Panchal on 2019-05-04.
//  Copyright © 2019 Siddharth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class VolunteerSignUpViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func getStarted(_ sender: Any) {
        guard let email = email.text, let password = password.text else {
            return
        }
        createUser(withEmail: email, password: password)
        self.performSegue(withIdentifier: "VolunteerViewSegue3", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func createUser(withEmail email:String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                print("Failed to sign user up with error: ", error.localizedDescription)
                return
            }
            
            let db = Firestore.firestore()
            
            guard (result?.user.uid) != nil else { return }
            
            var ref: DocumentReference? = nil
            ref = db.collection("users").addDocument(data: ["email": email]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
