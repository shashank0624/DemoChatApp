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
import FirebaseDatabase

class MessagesController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let user = User()
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    self.setupNavigationBarWithUser(user: user)
                    //self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
    }
    
    func setupNavigationBarWithUser(user : User){
       // self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.red
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)

        }

        titleView.addSubview(profileImageView)

        //iOS 9 contraints
        //need x,y, width , height anchor

        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLbl = UILabel()
         titleView.addSubview(nameLbl)
        nameLbl.text = user.name
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        //iOS 9 contraints
        //need x,y, width , height anchor
        nameLbl.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8.0).isActive = true
        nameLbl.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLbl.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLbl.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
       
        self.navigationItem.titleView = titleView
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        signOutFromFirebaseUser()
        performSegue(withIdentifier: "MainVCToLogin", sender: nil)
    }
    
    @IBAction func handleNewMessages(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MainVCToNewMessageVC", sender: nil)
    }
    
    
    @objc func forceLoggedOut(){
        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController{
            loginVC.messageController = self
            self.present(loginVC, animated: true, completion: nil)
        }
        
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
            if let loginVC = segue.destination as? LoginController{
                //Send data to Login Controller
                loginVC.messageController = self
            }
        }
        
        if segue.identifier == "MainVCToNewMessageVC"{
            if let _ = segue.destination as? NewMessagesController{
                //Send data to New Message Controller
                
            }
        }
    }
}

