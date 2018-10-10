//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 12/17/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

/*
References:
// Logout funcationality
http://stackoverflow.com/questions/28210572/swift-nshttpcookiestorage-count2


// Map mapKit
http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
http://stackoverflow.com/questions/25202613/mapkit-in-swift-part-2
http://stackoverflow.com/questions/33532883/add-different-pin-color-with-mapkit-in-swift-2-1
*/

import UIKit
import MapKit


class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
           mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logout as Left button on Navigation
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MapViewController.logoutRequest))
        self.navigationItem.leftBarButtonItem = logoutButton
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        putStudentLocationsOnTheMap()
    }
    
    func putStudentLocationsOnTheMap() {
        activityIndicator.startAnimating()
        mapView.alpha = 0.4
        ParseClient.sharedInstance.getStudentLocations() { success, errorMessage in
            var annotations = [MKPointAnnotation]()
            if success {
                for location in ParseClient.sharedInstance.locations {
                    let lat = CLLocationDegrees(location.latitude)
                    let long = CLLocationDegrees(location.longitude)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(location.firstName) \(location.lastName)"
                    annotation.subtitle = location.mediaURL
                                        
                    annotations.append(annotation)
                    
                    //REQ 10?
                }
            } else {
                //Display error message
                
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.activityIndicator.stopAnimating()
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotations(annotations)
                self.activityIndicator.stopAnimating()
                self.mapView.alpha = 1.0
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        putStudentLocationsOnTheMap()
    }

    
    @IBAction func pinDropButtonPressed(sender: AnyObject) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingView") as! LocationPostViewController
        self.presentViewController(infoPostController, animated: true, completion: nil)
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = ColorPointAnnotation(pinColor: UIColor.redColor())
        //annotation.coordinate = coordinate
        annotation.title = "title"
        annotation.subtitle = "subtitle"
        self.mapView.addAnnotation(annotation)
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            
            
            let colorPointAnnotation = annotation 
            pinView?.pinTintColor = colorPointAnnotation.pinColor
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == annotationView.rightCalloutAccessoryView)  {
            let sharedApp = UIApplication.sharedApplication()
            sharedApp.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
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


    @IBAction func logoutButtonPressed(sender: AnyObject) {
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
}
