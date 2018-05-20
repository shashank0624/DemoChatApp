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
    @IBOutlet weak var tableView: UITableView!
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        checkIfUserIsLoggedIn()
//        observeMessages()
        observeUserMessages()
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let message = Message()
                if let dict = snapshot.value as? [String: Any]{
                    message.text = dict["text"] as? String
                    message.fromId = dict["fromId"] as? String
                    message.toId = dict["toId"] as? String
                    message.timeStamp = dict["timestamp"] as? Int
                    //self.messages.append(message)
                    if let chatPartnerId = message.chatPartnerId(){
                        self.messageDictionary[chatPartnerId] = message
                        self.messages = Array(self.messageDictionary.values)
                        
                        self.messages = self.messages.sorted(by: { (message1, message2) -> Bool in
                            return message1.timeStamp! > message2.timeStamp!
                        })
                    }
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer : Timer?
    
    @objc func handleReloadTable(){
        DispatchQueue.main.async {
            print("Reload Messages")
            self.tableView.reloadData()
        }
    }
    
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            let message = Message()
            if let dict = snapshot.value as? [String: Any]{
                message.text = dict["text"] as? String
                message.fromId = dict["fromId"] as? String
                message.toId = dict["toId"] as? String
                message.timeStamp = dict["timestamp"] as? Int
                //self.messages.append(message)
                if let toId = message.toId{
                    self.messageDictionary[toId] = message
                    self.messages = Array(self.messageDictionary.values)
                    
                    self.messages = self.messages.sorted(by: { (message1, message2) -> Bool in
                        return message1.timeStamp! > message2.timeStamp!
                    })
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print(snapshot)
        }, withCancel: nil)
        
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
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        
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
//        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func showChatController(user: User){
        performSegue(withIdentifier: "messageVCToChatLogVC", sender: user)
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
            if let destination = segue.destination as? NewMessagesController{
                //Send data to New Message Controller
                destination.messagesController = self
                
            }
        }
        
        if segue.identifier == "messageVCToChatLogVC"{
            if let destination = segue.destination as? ChatLogControllerViewController{
                if let user = sender as? User{
                    destination.user = user
                }
            }
        }
    }
}

extension MessagesController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(messages)
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? NewMessagesCell{
            let message = messages[indexPath.row]
            cell.message = message
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
        let ref = Database.database().reference().child("Users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dict = snapshot.value as? [String : Any] else{
                return
            }
            let user = User()
            user.email = dict["email"] as? String
            user.name = dict["name"] as? String
            user.profileImageUrl = dict["profileImageUrl"] as? String
            user.userId = chatPartnerId
            
            self.performSegue(withIdentifier: "messageVCToChatLogVC", sender: user)
        }, withCancel: nil)
    }
}
