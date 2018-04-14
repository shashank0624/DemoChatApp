//
//  ViewController.swift
//  DemoChatApp
//
//  Created by Shashank Panwar on 4/14/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "MainVCToLogin", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainVCToLogin"{
            if let destination = segue.destination as? LoginController{
                
            }
        }
    }
}

