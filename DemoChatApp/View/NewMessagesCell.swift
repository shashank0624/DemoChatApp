//
//  NewMessagesCell.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 16/04/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase

class NewMessagesCell: UITableViewCell {

    var message: Message?{
        didSet{
            if let toId = message?.toId{
                let ref = Database.database().reference().child("Users").child(toId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String: Any]{
                        self.nameLbl.text = dict["name"] as? String
                        self.emailLbl.text = self.message?.text
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: dict["profileImageUrl"] as! String)
                    }
                }, withCancel: nil)
                
            }
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 25
        profileImageView.layer.masksToBounds = true
    }
    
}
