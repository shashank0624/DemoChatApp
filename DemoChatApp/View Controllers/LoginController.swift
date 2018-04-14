//
//  LoginController.swift
//  DemoChatApp
//
//  Created by Shashank Panwar on 4/14/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var inputContainerView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIContents()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setUpUIContents(){
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        registerButton.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        inputContainerView.layer.cornerRadius = 10
        inputContainerView.clipsToBounds = true
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
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
            //Successfully authenticated
            let ref = Database.database().reference(fromURL: "https://demochatapp-66b1b.firebaseio.com/")
            let userReference = ref.child("Users").child(user)
            let values = ["name": name, "Email-Id": email]
            userReference.updateChildValues(values)
            
        }
        
    }
    

}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
