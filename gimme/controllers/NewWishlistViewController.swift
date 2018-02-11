//
//  NewWishlistViewController.swift
//  gimme
//
//  Created by Daniel Mihai on 11/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit

class NewWishlistViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Segues.SaveNewWishlist {
            return false
        }
        
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }

    @IBAction func saveNewWishlist(_ sender: Any) {
        var canSaveWishlist = true
        
        if let wishlistName = nameTextField.text {
            if wishlistName.isEmpty {
                canSaveWishlist = false
                
                addAlert(title: AlertLabels.NameTitle, message: AlertLabels.NameMessage)
            }
        }
        
        NSLog("about to save wishlist")
        
        if canSaveWishlist {
            performSegue(withIdentifier: Segues.SaveNewWishlist, sender: self)
        }
    }
    
    private func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: false, completion: nil)
        
    }
    
    private struct AlertLabels {
        static let NameTitle = "Invalid Name"
        
        static let NameMessage = "Please enter a valid name."
    }
}
