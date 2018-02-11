//
//  WishlistsViewController.swift
//  gimme
//
//  Created by Daniel Mihai on 10/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

class WishlistsViewController: UITableViewController {

    private var wishlists = [Wishlist]()
    private var ref: DatabaseReference!
    private var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        ref = Database.database().reference().child("users").child(user.uid).child("wishlists");
        
        loadWishlists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ItemsView {
            if let destinationViewController = segue.destination as? ItemsViewController {
                if let wishListCell = sender as? WishlistTableViewCell {
                    if let wishlist = wishListCell.wishlist {
                        destinationViewController.wishlist = wishlist
                    }
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishlists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Wishlists, for: indexPath) as! WishlistTableViewCell
        let wishlist = wishlists[indexPath.row]
        
        cell.nameLabel?.text = wishlist.name
        cell.descriptionLabel?.text = wishlist.description
        cell.wishlist = wishlist
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deletedWishlist = wishlists.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
            deleteWishlist(wishlist: deletedWishlist)
        }
    }
    
    private func deleteWishlist(wishlist: Wishlist) {
        ref.child(wishlist.identifier).removeValue()
    }
    
    private func loadWishlists() {
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.wishlists.removeAll()
                
                for wishlistsObjects in snapshot.children.allObjects as! [DataSnapshot] {
                    let wishlistObject = wishlistsObjects.value as? [String: AnyObject]
                    let id = wishlistObject?["id"] as! String
                    let name = wishlistObject?["name"] as! String
                    let description = wishlistObject?["description"] as? String
                    
                    
                    
                    let wishlist = Wishlist(identifier: id, name: name, description: description ?? "")
                    
                    self.wishlists.append(wishlist)
                }
            }
            
            self.tableView.reloadData()
        });
    }

    @IBAction func logOutAction(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Logged out firebase")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func saveNewWishlist(segue: UIStoryboardSegue, sender: UIStoryboardSegue) {
        if let source = segue.source as? NewWishlistViewController {
            let key = ref.childByAutoId().key
            let newWishlist = [
                "id": key,
                "name": source.nameTextField.text!,
                "description": source.descriptionTextField.text!]
            
            ref.child(key).setValue(newWishlist)
        }
    }
}
