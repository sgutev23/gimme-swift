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
            
            deleteItem(indexPath: indexPath)
        }
    }
    
    private func deleteItem(indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.deleteMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: ButtonLabels.cancel, style: .cancel, handler: nil)
        let ok = UIAlertAction(title: ButtonLabels.ok, style: .default, handler: { (action) -> Void in
            let item = self.items.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.databaseRef.child(item.identifier).removeValue()
        });
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Items, for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        let itemKey = getItemKey(item: item)
        
        if let cachedImage = ImageCache.shared.get(itemKey){
            cell.picture.image = cachedImage
        } else {
            let pictureUrl = URL(string: item.pictureURL)!
            let pictureData = NSData(contentsOf: pictureUrl as URL)
            let image = UIImage(data: pictureData! as Data)
            
            cell.picture.image = image
            
            ImageCache.shared.set(itemKey, value: image!)
        }
        
        cell.item = item
        cell.nameLabel.text = item.name
        cell.descriptionLabel.text = item.description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.NewItemView {
            if let destination = segue.destination as? NewItemViewController {
                destination.wishlist = wishlist
            }
        } else if segue.identifier == Segues.ItemView {
            if let destination = segue.destination as? ItemViewController, let itemCell = sender as? ItemTableViewCell {
                destination.picture = ImageCache.shared.get(getItemKey(item: itemCell.item!))
                destination.item = itemCell.item
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
    
    private func getItemKey(item: Item) -> String {
        return (wishlist?.identifier)! + "-" + item.identifier
    }
}
