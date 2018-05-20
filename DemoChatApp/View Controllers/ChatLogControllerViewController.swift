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
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapShot) in
            let messageId = snapShot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value
                , with: { (snapshot) in
                    print(snapShot)
                    guard let dict = snapshot.value as? [String: Any] else{
                        return
                    }
                    let message = Message()
                    message.fromId = dict["fromId"] as? String
                    message.toId = dict["toId"] as? String
                    message.text = dict["text"] as? String
                    message.timeStamp = dict["timestamp"] as? Int
                    if message.chatPartnerId() == self.user?.userId{
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0 )
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0 )
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
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
        childRef.updateChildValues(values) { (error, ref) in
            if let err = error{
                print(err)
                return
            }
            self.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let receipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            receipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
}

extension ChatLogControllerViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    func setUpCell(cell : ChatMessageCell, message : Message){
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        
        if message.fromId == Auth.auth().currentUser?.uid{
            // Outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false

        }else{
            // Incoming Grey
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        
        if let text = messages[indexPath.row].text{
            height = estimateFrameForText(text: text).height + 20
        }
         
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}

extension ChatLogControllerViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}






