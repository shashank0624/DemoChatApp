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
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class ChatLogControllerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user : User?{
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    @IBOutlet weak var inputTextFieldIB: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var inputContainerViewIB: UIView!
    
    lazy var inputTextField : UITextField = {
       let textfield = UITextField()
        textfield.placeholder = "Enter Text Here..."
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        return textfield
    }()
    
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
                    self.messages.append(Message(dict: dict))
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        //scroll to the last index
                        let indexpath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexpath as IndexPath, at: .bottom, animated: true)
                    }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 68, right: 0 )
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0 )
        collectionView.keyboardDismissMode = .interactive
       setUpKeyBoardObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true 
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        //x,y,width,height
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
         uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton  = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        //x,y,width,height
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        get{
            return true
        }
    }
    
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            //We selected a video
            handleVideoSelectedFromUrl(url: videoUrl)
        }else{
            //We selected an image
            handleImageSelectedForInfo(info: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    private func handleVideoSelectedFromUrl(url : URL){
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil{
                print("Failed upload of videos", error)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                if let thumnailImage = self.thumbnailImageForFileUrl(url: url){
                    self.uploadImageToFirebaseStorage(image: thumnailImage, completion: { (imageUrl) in
                        
                        let properties : [String: Any] = ["imageUrl": imageUrl, "imageWidth": thumnailImage.size.width, "imageHeight": thumnailImage.size.height, "videoUrl": videoUrl]
                        self.sendMessageWithProperties(properties: properties)
                    })
                    
                }
            }
        }
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount{
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForFileUrl(url : URL) -> UIImage?{
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        return nil
    }
    
    
    private func handleImageSelectedForInfo(info: [String: Any]){
        var selectedImageFromPicker : UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            uploadImageToFirebaseStorage(image: selectedImage) { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            }
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping(_ imageUrl: String) -> ()){
       let imageName = NSUUID().uuidString
     let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil{
                    print("Failed to upload image : ", error?.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl)
                }
            }
        }
    }
    
    func setUpKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: Notification){
        if messages.count > 0{
            let indexpath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexpath as IndexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(notification: Notification){
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect{
            print("Height: \(keyboardFrame.height)")
            let keyboardDuration = notification.userInfo? [UIKeyboardAnimationDurationUserInfoKey] as? Double
            
            containerViewBottomAnchor.constant = keyboardFrame.height
            
            UIView.animate(withDuration: keyboardDuration!) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification){
        let keyboardDuration = notification.userInfo? [UIKeyboardAnimationDurationUserInfoKey] as? Double
        containerViewBottomAnchor.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
       handleSendMessage()
    }
    
    @objc func handleSendMessage(){
        let properties: [String: Any] = ["text": inputTextField.text!]
        sendMessageWithProperties(properties: properties)
    }
    
    func sendMessageWithImageUrl(imageUrl : String, image: UIImage){
        let properties : [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties : [String: Any]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.userId!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        //Append property dictionary somehow/////????
        properties.forEach({values[$0.key] = $0.value})
        
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
    
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startingImageView : UIImageView?
    
    func performingZoomInForStartingImageView(startingImageView: UIImageView){
        self.startingImageView =  startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1.0
                self.inputContainerView.alpha = 0
                //Height
                //h1 / w2 = h1/w1
                
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: (height))
                zoomingImageView.center = keyWindow.center
                
            }) { (completed) in
                
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        print("Handle Zoom out....")
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
       
        }
    }
}

extension ChatLogControllerViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        let message = messages[indexPath.row]
        cell.message = message
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        if let text = message.text{
            cell.textView.isHidden = false
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    func setUpCell(cell : ChatMessageCell, message : Message){
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            // Outgoing blue
            //cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
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
        
        let message = messages[indexPath.row]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue,let imageheight = message.imageHeight?.floatValue{
            height = CGFloat(imageheight / imageWidth * 200)
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






