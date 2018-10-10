//
//  LocationPostViewController.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 12/17/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
// References:
// http://stackoverflow.com/questions/30741481/swift-2-0-geocoder-argument-list
// https://developer.apple.com/library/prerelease/ios/documentation/CoreLocation/Reference/CLGeocoder_class/index.html
// http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
// http://stackoverflow.com/questions/31269716/activity-indicator-not-appearing
//

import UIKit
import MapKit

class LocationPostViewController: UIViewController, UITextFieldDelegate, UINavigationBarDelegate, MKMapViewDelegate {
    @IBOutlet weak var WhereAreYouStudingAndURLLinkTextFied: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var objectId: String?
    var previousMediaURL: String?
    var previousMapString: String?
    
    let geocoder: CLGeocoder = CLGeocoder()
    
    var boxView = UIView()
    
    // View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        self.WhereAreYouStudingAndURLLinkTextFied.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        //hideActivityIndicator()
        mapView.hidden = true
        findOnTheMapButton.hidden = false
        submitButton.hidden = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        ParseClient.sharedInstance.queryStudentLocation(Networking.sharedInstance.userID!) { results, error in
            if let locations = results {
                if locations.count > 0 {
                    self.objectId = locations[0].objectId
                    self.previousMapString = locations[0].mapString
                    self.previousMediaURL = locations[0].mediaURL
                    let alert = UIAlertController(title: "Overwrite?", message: "This User Has Already Posted a Student Location.  Would You Like To Overwrite Their Location?", preferredStyle: .Alert)
                    let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
                        self.locationTextField.text = self.previousMapString
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(overwriteAction)
                    alert.addAction(cancelAction)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error getting lcoations", message: "Error getting locations", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - newToolBarButtonForFindOrSubmit button method
    func findOnTheMapOrSubmit(newToolBarButtonForFindOrSubmit: UIBarButtonItem) {
        newToolBarButtonForFindOrSubmit.enabled = false
    }
    
    // Handle Find On The Map Button Pressed
    @IBAction func findOnTheMapButtonPressed(sender: AnyObject) {
        findOnTheMapButton.hidden = true
        submitButton.hidden = false
        if mapString == nil {
            findOnMap(locationTextField.text!)
        } else {
            locationSubmit()
        }
    }
    // Handle Submit Button Pressed
    @IBAction func submitButtonWasPressed(sender: UIButton) {
        WhereAreYouStudingAndURLLinkTextFied.endEditing(false)
        if  locationTextField.text != nil {
            locationSubmit()
        } else {
            let alert = UIAlertController(title: "Invalid location", message: "Enter location", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alert.addAction(dismissAction)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // Submit The Location
    func locationSubmit() {
        if let _ = locationTextField.text {
            if let _ = WhereAreYouStudingAndURLLinkTextFied.text {
                mediaURL = WhereAreYouStudingAndURLLinkTextFied.text
                if let _ = NSURL(string: mediaURL!) {
                    activityIndicator.startAnimating()
                    mapView.alpha = 0.5
                    let locationData: [String: AnyObject] = [
                        ParseClient.JSONResponseKeys.uniqueKey: Networking.sharedInstance.userID!,
                        ParseClient.JSONResponseKeys.firstName: Networking.sharedInstance.name!.first,
                        ParseClient.JSONResponseKeys.lastName: Networking.sharedInstance.name!.last,
                        ParseClient.JSONResponseKeys.mapString: mapString!,
                        ParseClient.JSONResponseKeys.mediaURL: mediaURL!,
                        ParseClient.JSONResponseKeys.latitude: latitude!,
                        ParseClient.JSONResponseKeys.longitude: longitude!
                    ]
                    if let id = objectId {
                        ParseClient.sharedInstance.putStudentLocation(id, data: locationData) { success, errorMessage in
                            self.postComplete( success, errorMessage: errorMessage )
                        }
                    } else {
                        ParseClient.sharedInstance.postStudentLocation(locationData) { success, errorMessage in
                            self.postComplete( success, errorMessage: errorMessage )
                        }
                    }
                    activityIndicator.stopAnimating()
                } else { // if let _ = NSURL(string: mediaURL!)
                    let alert = UIAlertController(title: "Invalid URL", message: "URL is not valid.", preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAction)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    alert.addAction(dismissAction)
                    WhereAreYouStudingAndURLLinkTextFied.text = ""
                } // if let _ = NSURL(string: mediaURL!)
            } else { // if let _ = WhereAreYouStudingAndURLLinkTextFied.text
                let alert = UIAlertController(title: "Invalid URL", message: "URL must be entered.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                alert.addAction(dismissAction)
                WhereAreYouStudingAndURLLinkTextFied.text = ""
            } // if let _ = WhereAreYouStudingAndURLLinkTextFied.text
        } else {
            let alert = UIAlertController(title: "Invalid Location", message: "Location is not valid", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alert.addAction(dismissAction)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            alert.addAction(dismissAction)
            locationTextField.text = ""
        } // if let _ = NSURL(string: locationTextField.text!)
    } // func locationSubmit()
    
    
    // Find location on The Map
    func findOnMap(location: String) {
        displayActivityIndicatorInABox()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        self.geocoder.geocodeAddressString(location) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?.first {
                //if let placemark = placemarks![0] as? CLPlacemark {
                    let coordinates = placemark.location!.coordinate
                    //Setup data for submission
                    self.latitude = coordinates.latitude as Double
                    self.longitude = coordinates.longitude as Double
                    self.mapString = location
                    let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(0.5, 0.5))
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    self.mapView.addAnnotation(annotation)
                    //Reconfigure display
                    dispatch_async(dispatch_get_main_queue()) {
                        self.removeActivityIndicatorInABoxFromView()
                        self.WhereAreYouStudingAndURLLinkTextFied.text = "Enter your link"
                        if self.previousMediaURL != nil {
                            self.locationTextField.text = self.previousMediaURL
                        } else {
                            self.locationTextField.text = "Enter URL"
                        }
                        //self.findOnTheMapButton.setTitle("Submit", forState: .Normal)
                        
                        self.mapView.alpha = 1.0
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.hidden = false
                    }
                }
            } else {
                let alert = UIAlertController(title: "Invalid Location", message: "Cannot Find That Location On The Map", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.locationTextField.text = ""
                    self.removeActivityIndicatorInABoxFromView()
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.removeActivityIndicatorInABoxFromView()
            })
        });
    }
    
    //Handle location post and put completion
    func postComplete( success: Bool, errorMessage: String? ) {
        if success {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alert.addAction(dismissAction)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.alpha = 1.0
            self.activityIndicator.stopAnimating()
        }
    }
    
    // Handle cancel submission
    @IBAction func cancelSubmission(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // Testfield Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    // Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Show spinner
    func showActivityIndicator()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        } )
    }
    
    // Hide Spinner
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        } )
    }
    
    
    func displayActivityIndicatorInABox() {
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.grayColor()
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinner is initialized
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.redColor()
        textLabel.text = "Geocoding..."
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
    }
    
    
    func removeActivityIndicatorInABoxFromView() {
        //removes the boxView from screen
        boxView.removeFromSuperview()
    }
}
