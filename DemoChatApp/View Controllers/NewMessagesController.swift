//
//  NewMessagesController.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 15/04/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase

class NewMessagesController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        }
        fetchUser()
        
    }
    
    func fetchUser(){
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any]{
                let user = User()
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                if let name = dict["name"] as? String{
                    user.name = name
                }
                if let email = dict["email"] as? String{
                    user.email = email
                }
                self.users.append(user)
                
                //this will crash because of background thread, so lets use
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? NewMessagesCell{
            let user = users[indexPath.row]
            cell.textLabel?.text  =  user.name
            cell.detailTextLabel?.text = user.email
            return cell
        }
       return UITableViewCell()
    }
    

}
