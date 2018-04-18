//
//  LoginController+handlers.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 18/04/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBAction func imageTappedForProfile(_ sender: UITapGestureRecognizer) {
        if sender.view == profileImageView{
            let picker = UIImagePickerController()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel Picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            print("\(originalImage.size)")
        }
    }
    
}
