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
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deletedItem = items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            deleteItem(item: deletedItem)
        }
    }
    
    private func deleteItem(item: Item) {
        databaseRef.child(item.identifier).removeValue()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Items, for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        let pictureUrl = URL(string: item.pictureURL)!
        let pictureData = NSData(contentsOf: pictureUrl as URL)
        
        cell.picture.image = UIImage(data: pictureData! as Data)
        cell.nameLabel.text = item.name
        cell.descriptionLabel.text = item.description
        
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
        databaseRef.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.items.removeAll()
                
                for itemsObjects in snapshot.children.allObjects as! [DataSnapshot] {
                    let itemObject = itemsObjects.value as? [String: AnyObject]
                    let id = itemObject?["id"] as! String
                    let name = itemObject?["name"] as! String
                    let description = itemObject?["description"] as? String
                    let pictureURL = itemObject?["downloadURL"] as? String
                    
                    let item = Item(identifier: id, name: name, description: description ?? "", pictureURL: pictureURL ?? "");
                    
                    print ("Got Item: \(item)")
                    self.items.append(item)
                }
            }
            
            self.tableView.reloadData()
        })
    }

    @IBAction func saveNewItem(segue: UIStoryboardSegue, sender: UIStoryboardSegue) {
        if let source = segue.source as? NewItemViewController {
            let key = self.databaseRef.childByAutoId().key
            let resizedPicture = cropAndScaleImage(scrollView: source.scrollView)
            let pictureData = (UIImagePNGRepresentation(resizedPicture))
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
    
    private func cropAndScaleImage(scrollView: UIScrollView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let pictureToSave = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return pictureToSave!
    }
}
