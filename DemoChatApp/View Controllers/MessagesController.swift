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

class MessagesController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(forceLoggedOut), with: nil, afterDelay: 0)
        }else{
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any]{
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        signOutFromFirebaseUser()
        performSegue(withIdentifier: "MainVCToLogin", sender: nil)
    }
    
    @IBAction func handleNewMessages(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MainVCToNewMessageVC", sender: nil)
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
            if let _ = segue.destination as? LoginController{
                //Send data to Login Controller
            }
        }
        
        if segue.identifier == "MainVCToNewMessageVC"{
            if let _ = segue.destination as? NewMessagesController{
                //Send data to New Message Controller
                
            }
        }
    }
}

