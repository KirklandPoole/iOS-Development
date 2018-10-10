//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/31/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

/*
References:
http://stackoverflow.com/questions/28210572/swift-nshttpcookiestorage-count2
*/

import UIKit

class TableViewController: UITableViewController {

    override func viewWillAppear(animated: Bool) {
        // Add logout as Left button on Navigation
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TableViewController.logoutRequest))
        self.navigationItem.leftBarButtonItem = logoutButton
        getStudentLocationData()
    }
    
    func getStudentLocationData() {
        ParseClient.sharedInstance.getStudentLocations() { success, errorMessage in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.tableView.reloadData()
                }
            } else {
                //Display error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }

    }
    
    func logoutRequest() {
        Networking.sharedInstance.logout() { success, error in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject)  {
        Networking.sharedInstance.logout() { success, error in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        self.tableView.reloadData()
    }

    @IBAction func pinDropButtonPressed(sender: UIButton) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingView") as! LocationPostViewController
        self.presentViewController(infoPostController, animated: true, completion: nil)
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "StudentLocationCells"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        let studentLocation = ParseClient.sharedInstance.locations[indexPath.row]
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel?.text = studentLocation.mediaURL
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance.locations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = ParseClient.sharedInstance.locations[indexPath.row]
        let application = UIApplication.sharedApplication()
        if let url = NSURL(string: studentLocation.mediaURL) {
            application.openURL( url )
        } else {
            print("ERROR: Invalid url")
        }
    }
    
}

