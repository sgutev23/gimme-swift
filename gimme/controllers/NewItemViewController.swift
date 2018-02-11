//
//  NewItemViewController.swift
//  gimme
//
//  Created by Daniel Mihai on 11/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate  {
    
    var imageView = UIImageView()
    var wishlist: Wishlist? = nil

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            resetScrollView()
            scrollView.delegate = self
        }
    }
    
    @IBAction func saveItem(_ sender: Any) {
        var canSaveItem = true
        
        if let itemName = nameTextField.text {
            if itemName.isEmpty {
                canSaveItem = false
                
                addAlert(title: AlertLabels.NameTitle, message: AlertLabels.NameMessage)
            }
        }
        
        if canSaveItem {
            performSegue(withIdentifier: Segues.SaveNewItem, sender: self)
        }
    }
    @IBAction func addPhoto(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.allowsEditing = false
        imageController.delegate = self
        
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            imageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.present(imageController, animated: true, completion: nil)
        }
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
                imageController.sourceType = UIImagePickerControllerSourceType.camera
                
                self.present(imageController, animated: true, completion: nil)
            }
            
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizer()
        
        scrollView.addSubview(imageView)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        imageView.image = image
        imageView.sizeToFit()
        resetScrollView()
        picker.dismiss(animated: true,completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        let imageViewSize = imageView.frame.size
//        let scrollViewSize = scrollView.bounds.size
//
//        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func resetScrollView() {
        scrollView?.contentSize = imageView.frame.size
        
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = 1.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if(scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
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
