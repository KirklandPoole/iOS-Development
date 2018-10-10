//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
////
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563
// http://stackoverflow.com/questions/27880588/uialertcontroller-as-an-action-in-swift

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var mapSettings: MapSettings?
    var lastAnnotation = MKPointAnnotation()
    
    // MARK: - Pointer to core data shared context
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSettings = fetchMapSettings()  // get map setting from database
        configureMap() // update map
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true
        self.addTapOnTheMapRecognizer()
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        addAnAnnotatonToTheMapView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeTapOnTheMapRecognizer()
    }
    
    // MARK: - Handle Taps
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func removeTapOnTheMapRecognizer() {
        self.mapView.removeGestureRecognizer(longPressGestureRecognizer!)
    }
    
    func addTapOnTheMapRecognizer() {
        self.mapView.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    //  Get map setting from databasse
    func fetchMapSettings() -> MapSettings {
        var error: NSError?
        let fetchRequest = NSFetchRequest(entityName: "MapSettings")
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        // Handle fetch error
        if let error = error {
            self.displayOkAlertToUser("Error in fetchMapSettings: \(error)")
        }
        // Use the default location... Miami Beach, of course...One Day...
        if results?.count == 0 {
            // Lat , Long for Miami Beach, Florida
            let dictionary: [String: Double] = [
                MapSettings.Keys.latitudeDelta: 0.1,
                MapSettings.Keys.longitudeDelta: 0.1,
                MapSettings.Keys.latitude: 25.7902778,
                MapSettings.Keys.longitude: -80.1302778
            ]
            let defaultMapsSettings = MapSettings(dictionary: dictionary, context: sharedContext)
            
            //CoreDataManager.sharedInstance().saveContext()
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataManager.sharedInstance().saveContext()
            }) // dispatch_async(dispatch_get_main_queue()
            
            return defaultMapsSettings
        }
        return (results as! [MapSettings]).first! // First record in database
    }
    
    // MARK: - Actions
    
    
    func getCoordFromPoint(gesture: UILongPressGestureRecognizer) -> CLLocationCoordinate2D {
        let locationInView = gesture.locationInView(mapView)
        return mapView.convertPoint(locationInView, toCoordinateFromView: mapView)
    }
    
    func addPinToTheMap(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            // bBgin of touch action
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = getCoordFromPoint(gestureRecognizer)
            lastAnnotation = newAnnotation
            mapView.addAnnotation(newAnnotation)
        case .Changed:
            // Changing action
            lastAnnotation.coordinate = getCoordFromPoint(gestureRecognizer)
        case .Ended:
            // End of acton
            savePinWithCoreData(lastAnnotation)
            do {
                try fetchedResultsController.performFetch()
            } catch  {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        default:
            self.displayOkAlertToUser("Unexpected error occured in addPinToTheMap")
        }
    }
    
    func savePinWithCoreData(annotation: MKPointAnnotation) {
        let dictionary: [String: Double] = [
            Pin.Keys.Latitude: annotation.coordinate.latitude,
            Pin.Keys.Longitude: annotation.coordinate.longitude
        ]
        let newPin = Pin(dictionary: dictionary, context: sharedContext)
        
        //CoreDataManager.sharedInstance().saveContext()
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataManager.sharedInstance().saveContext()
        }) // dispatch_async(dispatch_get_main_queue()
        
        // Prefetch Photos for the pin - speed improvement
        prefetchPhotosForPin(newPin)
    }
    
    func prefetchPhotosForPin(newPin: Pin) {
        GetDataFromFlicker.sharedInstance().searchPhotosWithLatitudeAndLangitude(newPin.latitude, longitude: newPin.longitude, pageNumber: 1) { URLArray, error, totalPages in
            if error == nil {
                if totalPages > newPin.flickrPage.integerValue {
                    newPin.flickrPage = NSNumber(integer: newPin.flickrPage.integerValue+1)
                }
                //CoreDataManager.sharedInstance().saveContext()
                
                dispatch_async(dispatch_get_main_queue(), {
                    CoreDataManager.sharedInstance().saveContext()
                }) // dispatch_async(dispatch_get_main_queue()
                
                for (key, value) in URLArray! {
                    let dictionaryOfPhotos = [Photo.Keys.ID: key, Photo.Keys.URL: value]
                    let photo = Photo(dictionary: dictionaryOfPhotos, context: self.sharedContext)
                    photo.pin = newPin
                    _ = GetDataFromFlicker.sharedInstance().taskForImage(photo.url) { data, error in
                        if error == nil {
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue()) {
                                photo.flickrImage = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addAnAnnotatonToTheMapView() {
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        let sectionInfo = self.fetchedResultsController.sections![0]
        //for(var i = 0; i < sectionInfo.numberOfObjects; i += 1) {
        if (sectionInfo.numberOfObjects > 0) {
            for i in 0...(sectionInfo.numberOfObjects - 1) {
                let pinFromDataBase = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! Pin
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pinFromDataBase.latitude, longitude: pinFromDataBase.longitude)
                mapView.addAnnotation(annotation)
            }
        } //  if (sectionInfo.numberOfObjects > 0)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var mapPinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        if mapPinAnnotationView == nil {
            mapPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            mapPinAnnotationView!.draggable = false
            mapPinAnnotationView!.canShowCallout = false
        } else {
            mapPinAnnotationView!.annotation = annotation
        }
        return mapPinAnnotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let photoAlbumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoAlbumViewControllerIdentifier") as! PhotoAlbumViewController
        var pinFromDataBase: Pin?
        let sectionInfo = self.fetchedResultsController.sections![0]
        //for(var i = 0; i < sectionInfo.numberOfObjects; i += 1) {
        if (sectionInfo.numberOfObjects > 0) {
            for i in 0...(sectionInfo.numberOfObjects - 1) {
                pinFromDataBase = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? Pin
                if pinFromDataBase?.latitude == view.annotation!.coordinate.latitude && pinFromDataBase?.longitude == view.annotation!.coordinate.longitude {
                    break
                }
            } // if (sectionInfo.numberOfObjects > 0)
        }
        // Set a pin in the PhotoAlbumViewController
        photoAlbumViewController.currentPin = pinFromDataBase
        // Push PhotoAlbumViewController into view
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
    
    // Save data if there's a region change
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
            mapSettings?.longitudeDelta = mapView.region.span.longitudeDelta
            mapSettings?.latitudeDelta  = mapView.region.span.latitudeDelta
            mapSettings?.longitude      = mapView.region.center.longitude
            mapSettings?.latitude       = mapView.region.center.latitude
        
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataManager.sharedInstance().saveContext()
        }) // dispatch_async(dispatch_get_main_queue()
        
    }
    
    // MARK: - Configure Map
    
    func configureMap() {
        let spanOfRegion = MKCoordinateSpanMake(mapSettings!.latitudeDelta, mapSettings!.longitudeDelta)
        let currentRegion = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: mapSettings!.latitude, longitude: mapSettings!.longitude), spanOfRegion)
        mapView.setRegion(currentRegion, animated: true)
        //  Handle Tap Recognizer
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addPinToTheMap(_:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.4
    }
    
    // MARK: - User Alert
    
    func displayOkAlertToUser(message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
            { action -> Void in
                // Put your code here
            })
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
