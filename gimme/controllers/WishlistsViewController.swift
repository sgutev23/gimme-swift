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

class WishlistsViewController: UITableViewController {

    private var wishlists = [Wishlist]()
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.descriptionLabel?.text = wishlist.name
        cell.wishlist = wishlist
        
        return cell
    }
    
    func loadWishlists() {
        ref = Database.database().reference()
        
        self.wishlists.append(Wishlist(identifier: "1", name: "Test Wishlist 1", description: "Test Description 1"))
        self.wishlists.append(Wishlist(identifier: "2", name: "Test Wishlist 2", description: "Test Description 2"))
        self.wishlists.append(Wishlist(identifier: "3", name: "Test Wishlist 3", description: "Test Description 3"))
        self.tableView.reloadData()
    }

}
