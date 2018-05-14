//
//  ChatLogControllerViewController.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 03/05/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatLogControllerViewController: UIViewController {
    
    var user : User?{
        didSet{
            navigationItem.title = user?.name
        }
    }
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
       handleSendMessage()
    }
    
    func handleSendMessage(){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.userId!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values)
    }
}

extension ChatLogControllerViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
}






