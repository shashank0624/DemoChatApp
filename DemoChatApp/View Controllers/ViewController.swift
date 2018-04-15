//
//  ViewController.swift
//  DemoChatApp
//
//  Created by Shashank Panwar on 4/14/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //User not logged in
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(forceLoggedOut), with: nil, afterDelay: 0)
        }
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        signOutFromFirebaseUser()
        performSegue(withIdentifier: "MainVCToLogin", sender: nil)
    }
    
    @objc func forceLoggedOut(){
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginController")
        self.present(loginVC!, animated: true, completion: nil)
    }
    
    func signOutFromFirebaseUser(){
        do{
            try Auth.auth().signOut()
        }catch let logOutError{
            print("Logout Error: \(logOutError)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainVCToLogin"{
            if let destination = segue.destination as? LoginController{
                
            }
        }
    }
}

