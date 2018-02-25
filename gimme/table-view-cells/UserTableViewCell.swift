//
//  UserCell.swift
//  gimme
//
//  Created by Stan Gutev on 25.02.18.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    var user: AppUser?
    
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var name: UILabel!
}
