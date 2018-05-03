//
//  ChatLogControllerViewController.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 03/05/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatLogControllerViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chat Log Controller"
    }
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
       handleSendMessage()
    }
    
    func handleSendMessage(){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text": inputTextField.text!]
        childRef.updateChildValues(values)
    }
}

extension ChatLogControllerViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
}






