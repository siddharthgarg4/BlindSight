//
//  ViewController.swift
//  BlindSight
//
//  Created by Siddharth on 04/05/19.
//  Copyright © 2019 Siddharth. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation
import FirebaseFirestore
import Firebase

class HomeViewController: UIViewController {
    @IBOutlet weak var loginStatus: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var db: Firestore!
    
    
    @IBAction func iWantToHelpButtonPressed(_ sender: Any) {
        print("Button Pressed")
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "VolunteerViewSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "VolunteerSignInViewSegue", sender: self)
        }
    }
    
    @IBAction func iNeedHelpButtonPressed(_ sender: Any) {
        //create a dummy user as well
        let db = Firestore.firestore()
        
        var ref: DocumentReference? = nil
        ref = db.collection("blindUsers").addDocument(data: ["needsHelp": false]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                UserDefaults.standard.set(ref!.documentID, forKey: "blindUID")
            }
        }
        
        self.performSegue(withIdentifier: "RecognitionSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View Loaded")
        if Auth.auth().currentUser != nil {
            print("logged in")
            loginStatus.isHidden = false
        } else {
            loginStatus.isHidden = true
        }
        loginStatus.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeup))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        playAudio()
        
    }
    
    func playAudio() {
        if let fileURL = Bundle.main.path(forResource: "1", ofType: "mp3") {
            print("Continue processing")
        } else {
            print("Error: No file with specified name exists")
        }
        do {
            if let fileURL = Bundle.main.path(forResource: "1", ofType: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        audioPlayer?.play()
        audioPlayer?.numberOfLoops = 0
        
//        playAudio2()
    }
    
    func playAudio2() {
        if let fileURL = Bundle.main.path(forResource: "2", ofType: "mp3") {
            print("Continue processing")
        } else {
            print("Error: No file with specified name exists")
        }
        do {
            if let fileURL = Bundle.main.path(forResource: "2", ofType: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        audioPlayer?.play()
        audioPlayer?.numberOfLoops = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            print("logged in")
            loginStatus.isHidden = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            loginStatus.isHidden = true
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func swipeup() {
        self.performSegue(withIdentifier: "RecognitionSegue", sender: self)
    }

}

