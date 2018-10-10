//
//  MemeEditorViewController.swift
//  Meme1
//
//  Created by Kirkland Poole on 12/8/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var textFieldTop: UITextField!       //TextField at top of screen
    @IBOutlet weak var textFieldBottom: UITextField!    //TextField at bottom of screen
    @IBOutlet weak var imageView: UIImageView!          //Photo image
    @IBOutlet weak var cameraButton: UIBarButtonItem!   //Camera button
    @IBOutlet weak var shareButton: UIBarButtonItem!    //Share buton
    
    // MARK: closure for textfield
    func lend<T where T:NSObject> (closure:(T)->()) -> T {
        let orig = T()
        closure(orig)
        return orig
    }


    // MARK: view lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Camera is disabled by default. 
        // Enable the camera if it is supported by the device
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            cameraButton.enabled = true
        }
        // set text field delegate
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
        configureTextFields()
        
        
    }
    
    
    
        override func viewWillAppear(animated: Bool) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
    // MARK: Handle button actions
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func photoAlbumButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let memedImage : UIImage = generateMemedImage()
        save()
        let objectsToShare = [memedImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Enable / Disable share button
    func shareButtonEnableToggle() {
        if (imageView.image == nil) {
            shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
    }
    
    // MARK: Handle imagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let selectedImage : UIImage = image
        imageView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        shareButtonEnableToggle()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        shareButtonEnableToggle()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // fetch the selected image
        if picker.allowsEditing {
            imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        } else {
            imageView.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Handle textFields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    
    func configureTextFields() {
        if (textFieldTop.attributedText?.length > 0) {
            textFieldTop.attributedText = makeAttributedString(textFieldTop.text!)
        }
        if (textFieldBottom.attributedText?.length > 0) {
            textFieldBottom.attributedText = makeAttributedString(textFieldBottom.text!)
        }
    }
    
    
    // Set the attributes for the text fields
    func makeAttributedString(s1: String) -> NSAttributedString {
        var content : NSMutableAttributedString!
        content = NSMutableAttributedString(string:s1, attributes:[
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0
            ])
        content.addAttribute(NSParagraphStyleAttributeName,
            value:lend(){
                (para:NSMutableParagraphStyle) in
                para.headIndent = 10
                para.firstLineHeadIndent = 10
                para.tailIndent = -10
                para.lineBreakMode = .ByWordWrapping
                para.alignment = .Center
                para.paragraphSpacing = 15
            }, range:NSMakeRange(0,1))
        let end = content.length
        content.replaceCharactersInRange(NSMakeRange(end, 0), withString:"\n")
        return content
    }
    
    
    // MARK: Handle Keyboard
    // move view up when entering text at bottom of screen
    func keyboardWillShow(sender: NSNotification) {
        if (textFieldBottom.isFirstResponder()) {
            if let userInfo = sender.userInfo {
                if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                    view.frame.origin.y -= keyboardHeight
                }
            }
        }
    }
    
    // move view down after entering text at bottom of screen
    func keyboardWillHide(sender: NSNotification) {
        if (textFieldBottom.isFirstResponder()) {
            if let userInfo = sender.userInfo {
                if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                    view.frame.origin.y += keyboardHeight
                }
            }
        }
    }
    
    // subscribe to keyboard notification for keyboardWillShow events
    func subscriptToKeyboardNotifications(meme: Meme) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    // MARK: Save Meme Data
    // save the meme data to a struct
    func save() {
        //Create the meme object
        let meme = Meme(textString1: textFieldTop.text, textString2: textFieldBottom.text, imageUIImage: imageView.image, memedImageUIImage: generateMemedImage())
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    
    // MARK: Generate Meme
    func generateMemedImage() -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    
}

