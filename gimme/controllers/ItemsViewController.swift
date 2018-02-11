//
//  ItemsViewController.swift
//  gimme
//
//  Created by Daniel Mihai on 10/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

class ItemsViewController: UITableViewController {
    
    var items = [Item]()
    var wishlist: Wishlist? = nil
    
    private var databaseRef: DatabaseReference!
    private var user: User!
    private var storageRef: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference().child("users").child(user.uid).child("wishlists").child((wishlist?.identifier)!).child("items")
        
        loadItems()
        self.title = wishlist?.name
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Items, for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        
        cell.nameLabel?.text = (wishlist?.name)! + " - " + item.name
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.NewItemView {
            if let destination = segue.destination as? NewItemViewController {
                destination.wishlist = wishlist
            }
        }
    }
    
    func loadItems() {
        self.items.append(Item(identifier: "1", name: "Item 1"))
        self.items.append(Item(identifier: "2", name: "Item 2"))
        self.items.append(Item(identifier: "3", name: "Item 3"))
        self.tableView.reloadData()
    }

    @IBAction func saveNewItem(segue: UIStoryboardSegue, sender: UIStoryboardSegue) {
        if let source = segue.source as? NewItemViewController {
            let key = self.databaseRef.childByAutoId().key
            let resizedPicture = source.imageView //TODO: resize
            let pictureData = (UIImagePNGRepresentation(resizedPicture.image!))
            let imageStorageRef = storageRef.child("items").child("wishlist-" + (wishlist?.identifier)!).child("items").child(key + ".jpg")
            
            _ = imageStorageRef.putData(pictureData!, metadata: nil) { (metadata, error) in
                if let error = error {
                    print ("Cannot save image: " + error.localizedDescription)
                } else {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let newItem = [
                        "id": key,
                        "downloadURL": downloadUrl?.absoluteString as Any,
                        "name": source.nameTextField.text!,
                        "description": source.descriptionTextField.text!] as [String : Any]
                    
                    self.databaseRef.child(key).setValue(newItem)
                }
            }
        }
    }
}
