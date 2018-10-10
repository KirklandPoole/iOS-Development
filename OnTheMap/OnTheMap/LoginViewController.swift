//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 12/17/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set UITextFieldDelegate for textfield objects
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    
    // MARK: - Handle Login Button Pressed
    @IBAction func loginButtonPressed(sender: AnyObject) {
        // Connect to API and verify user credentials (username + password)
        Networking.sharedInstance.loginWithUsernamePassword( emailTextField.text!, password: passwordTextField.text!) { (success, error) in
            
            if success {
                // Login was successsful
                // Load TabBarController Controller
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                //Handle errors
                if error == Networking.Messages.loginError {
                    dispatch_async(dispatch_get_main_queue()) {
                        //Alert: Incorrect username or password
                        self.passwordTextField.text = ""
                        print("Networking: username/password error")
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alert.addAction(dismissAlert)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    // Alert: Connection Error
                    dispatch_async(dispatch_get_main_queue()) {
                        print("Networking: Connection Errors")
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alert.addAction(dismissAlert)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }  
    }
    
    
    // MARK: Handle User does not have an account
    @IBAction func dontHaveAnAccountButtonPressed(sender: AnyObject)
        {UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        //{UIApplication.sharedApplication().openURL(NSURL(string: "http://www.udacity.com")!)
    }
    
    // MARK: Handle facebook login
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.facebook.com")!)
    }

     // MARK: -  Show Alert With Completion Handle
    func showAlertWithCompletion(title:String, message:String, buttonTitle:String = "OK", completion:((UIAlertAction!)->Void)!){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAlertAction = UIAlertAction(title: buttonTitle, style: .Default, handler: completion)
        alert.addAction(okAlertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Handle textFields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}
