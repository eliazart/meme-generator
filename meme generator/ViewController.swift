//
//  ViewController.swift
//  meme generator
//
//  Created by Eliazar Terrazas on 1/23/17.
//  Copyright © 2017 Eliazar Terrazas. All rights reserved.
//
import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var imagePicker: UIImageView!
   
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
   
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    @IBOutlet weak var AlbumButton: UIToolbar!
    
    
    @IBAction func PickAnImageFromAlbum(_ sender: AnyObject) {
        imagePickerRegister("Photo")
    }
    @IBAction func PickAnImageFromCamera(_ sender: AnyObject) {
        imagePickerRegister("Camera")
    }
    
    func imagePickerRegister(_ type : String){
        
        //Figure out which resource to call
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = (type == "Photo") ? UIImagePickerControllerSourceType.photoLibrary : UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        
        shareButton.isEnabled = true //Enable share button after image picked.
        
    }
    
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    
    //Define my text for my memes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 48)!,
        NSStrokeWidthAttributeName : -3.0        ] as [String : Any]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        lowerTextField.delegate = self
        styleTextField(topTextField)
        styleTextField(lowerTextField)
    }
    
    func styleTextField(_ textField: UITextField){
        
        //Style our text fields
        textField.text = "type here"
        textField.defaultTextAttributes = memeTextAttributes
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.textAlignment = NSTextAlignment.center
    }
    
    func textFieldShouldReturn (_ textField: UITextField) -> Bool{
        topTextField.resignFirstResponder()
        lowerTextField.resignFirstResponder()
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //Subscribe to keyboard notification events
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            unsubscribeFromKeyboardNotifications()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePicker.image = image
            dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func imageCancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)}
    
    
    
    func subscribeToKeyboardNotifications() {
        
        //Keyboard is going to appear. Change the height.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        //Keyboard closing. Bring y axis back
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if lowerTextField.isFirstResponder {
            //Bring up y axis by keyboard height
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
            //Reset keyboard value
            view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        //Get the height of the keyboard
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save(_ memedImage : UIImage) {
        // Create the meme
        let meme = Meme(topTextField: topTextField.text!, lowerTextField : lowerTextField.text!, imageView: imagePicker.image!, memedImage: memedImage)
        //Add meme to array in app delegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        _ = (UIApplication.shared.delegate as! AppDelegate).memes
        
        }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar
        toolBar.isHidden = true
        AlbumButton.isHidden = true
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.toolbar.isHidden = true

        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar
        AlbumButton.isHidden = false
        toolBar.isHidden = false

        
        return memedImage
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        //Call UIActivityViewController
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Handler for completion
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            
            if(success == true){
                //Generate a memed image
                self.save(memedImage);
                
                //Dismiss
                self.dismiss(animated: true, completion: nil)
            }

        }
    }
}





