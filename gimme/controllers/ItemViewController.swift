//
//  ItemViewController.swift
//  gimme
//
//  Created by Daniel Mihai on 17/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ItemViewController: UIViewController {

    var item: Item? = nil
    var picture: UIImage? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var user: User!
    private var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = item?.name
        descriptionLabel.text = item?.description
        imageView.image = picture
    }
}
