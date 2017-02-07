//
//  ViewController.swift
//  meme generator
//
//  Created by Eliazar Terrazas on 1/23/17.
//  Copyright © 2017 Eliazar Terrazas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var ImagePicker: UIImageView!
   
    
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    @IBOutlet weak var AlbumButton: UIToolbar!
    
    
    @IBAction func PickAnImageFromAlbum(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func PickAnImageFromCamera(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
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
        topTextField.text = "type here"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.center
        topTextField.backgroundColor = UIColor.clear
        topTextField.borderStyle = .none
        lowerTextField.delegate = self
        lowerTextField.text = "type here"
        lowerTextField.defaultTextAttributes = memeTextAttributes
        lowerTextField.textAlignment = NSTextAlignment.center
        lowerTextField.backgroundColor = UIColor.clear
        lowerTextField.borderStyle = .none
        
        
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
            ImagePicker.image = image
            dismiss(animated: true, completion: nil)
        }
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
    }

    
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
        
        if lowerTextField.isFirstResponder
        {
            //Reset keyboard value
            view.frame.origin.y += getKeyboardHeight(notification)

        }
        
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        //Get the height of the keyboard
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save(_ memedImage : UIImage) {
        // Create the meme
        let meme = Meme(topTextField: topTextField.text!, lowerTextField : lowerTextField.text!, imageView: imageView.image!, memedImage: memedImage)
    }
}

