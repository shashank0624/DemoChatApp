//
//  LoginController+handlers.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 18/04/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleNewUserRegister(){
        guard let email = emailTextField.text , let password = passwordTextField.text, let name = nameTextField.text else{
            print("Invalid Details")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print("Error : \(error.localizedDescription)")
                return
            }
            guard let user = user?.uid else{
                return
            }
            
            let imageName = NSUUID().uuidString
            if let image = self.profileImageView.image{
                if let uploadData = UIImageJPEGRepresentation(image, 0.1){
                    let storageRef = Storage.storage().reference().child("Profile_Images").child("\(imageName).jpg")
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if let error = error{
                            print(error)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabase(withUid: user, values: values)
                        }
                    })
                }
            }
        }
    }
    
    private func registerUserIntoDatabase(withUid user: String,values:[String: Any]){
        //Successfully authenticated
        let ref = Database.database().reference(fromURL: "https://demochatapp-66b1b.firebaseio.com/")
        let userReference = ref.child("Users").child(user)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            //successfully saved in firebase database
            if let err = err{
                print(err.localizedDescription)
                return
            }
            //TODO: NEED TO CHANGE NAVIGATION BAR TITILE
            self.messageController?.navigationItem.title = values["name"] as? String
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func imageTappedForProfile(_ sender: UITapGestureRecognizer) {
        if sender.view == profileImageView{
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel Picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}
