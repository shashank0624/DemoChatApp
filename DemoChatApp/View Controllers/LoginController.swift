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
    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!
    
    @IBOutlet weak var inputContainerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextFieldHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfLineBetweenNameAndEmailContraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldHeightContraint: NSLayoutConstraint!
    
    var messageController : MessagesController?
    
    
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
    
    @IBAction func loginRegisterPressed(_ sender: UIButton) {
        if loginRegisterSegment.selectedSegmentIndex == 0{
            handleUserLogin()
        }else{
            handleNewUserRegister()
        }
    }
    
    func handleUserLogin(){
        guard let email = emailTextField.text , let password = passwordTextField.text else{
            print("Invalid Details")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let loginError = error{
                print("Authentication Error: \(loginError.localizedDescription)")
                return
            }
            //successfully login
            //TODO: NEED TO CHANGE NAVIGATION BAR TITILE
            self.messageController?.checkIfUserIsLoggedIn()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func loginRegisterSegmentChanged(_ sender: UISegmentedControl) {
        //Handle register or login button title
        let buttonTitle = sender.titleForSegment(at: sender.selectedSegmentIndex)
        registerButton.setTitle(buttonTitle, for: .normal)
    
        //Handle the size of the input container View
        inputContainerViewHeightContraint.isActive = false
        inputContainerViewHeightContraint = inputContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (sender.selectedSegmentIndex == 0 ? 0.15 : 0.3))
        inputContainerViewHeightContraint.isActive = true
        
        //Handle the name Text field for each segment
        nameTextFieldHeightContraint.isActive = false
        nameTextFieldHeightContraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: (sender.selectedSegmentIndex == 0 ? 0 : 1/3))
        nameTextFieldHeightContraint.isActive = true
        
        //Handle the size of email Text Field for each segment
        emailTextFieldHeightContraint.isActive = false
        emailTextFieldHeightContraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: (sender.selectedSegmentIndex == 0 ? 1/2 : 1/3))
        emailTextFieldHeightContraint.isActive = true
        
        if let lineHeight = heightOfLineBetweenNameAndEmailContraint{
            lineHeight.isActive = false
            lineHeight.constant = (sender.selectedSegmentIndex == 0 ? 0 : 1)
            lineHeight.isActive = true
        }
    }
    
}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
