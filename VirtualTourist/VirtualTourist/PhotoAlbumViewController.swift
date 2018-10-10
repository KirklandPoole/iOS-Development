//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563
// https://docs.google.com/document/d/1CYwX7fg0v7hNxVU-GGPMSHhv88P85FjHHI3ETDHqYo0/pub?embedded=true
// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html
// http://stackoverflow.com/questions/27880588/uialertcontroller-as-an-action-in-swift
//
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var photoCollectionFlowLayout: UICollectionViewFlowLayout!
    
    var newCollectionButton: UIBarButtonItem!  // button to get new collection
    
    //  Objects inserted, deleted, and updated.
    var indexPathsThatWereInserted: [NSIndexPath]!
    var indexPathsThatWereUpdated: [NSIndexPath]!
    var indexPathsThatWereDeleted: [NSIndexPath]!
    
    var currentPin: Pin! // current pin
    
    let pendingOperations = PendingOperations() // Queue Operations
    
    let totalPagesMax = 133
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureUI()
        
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (fetchedResultsController.sections![0] ).numberOfObjects == 0 {
            newCollectionButton.enabled = false
            photoCollection.allowsSelection = false
            getPinURLs()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //CoreDataManager.sharedInstance().saveContext()  // save database objects
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataManager.sharedInstance().saveContext()
        }) // dispatch_async(dispatch_get_main_queue()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoCollectionFlowLayout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        photoCollectionFlowLayout.minimumInteritemSpacing = 1
        photoCollectionFlowLayout.minimumLineSpacing = 1
        let widthOfPhotoCell = floor(self.photoCollection.frame.size.width/3 - 1)
        photoCollectionFlowLayout.itemSize =  CGSize(width: widthOfPhotoCell, height: widthOfPhotoCell)
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.currentPin)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    } ()
    
    // MARK: - NewCollection
    func addNewCollection(newCollectionButton: UIBarButtonItem) {
        photoCollection.allowsSelection = false
        newCollectionButton.enabled = false
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        //CoreDataManager.sharedInstance().saveContext()
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataManager.sharedInstance().saveContext()
        }) // dispatch_async(dispatch_get_main_queue()
        getPinURLs()
    }
    
    func getPinURLs() {
        GetDataFromFlicker.sharedInstance().searchPhotosWithLatitudeAndLangitude(currentPin.latitude, longitude: currentPin.longitude, pageNumber: currentPin.flickrPage.integerValue) { URLArray, error, totalPages in
            
            if let error = error {
                self.displayOkAlertToUser("Error getPinURLs: \(error)")
            } else {
                
                /*
                if totalPages > self.currentPin.flickrPage.integerValue && self.currentPin.flickrPage.integerValue <= self.totalPagesMax {
                    self.currentPin.flickrPage = NSNumber(integer: self.currentPin.flickrPage.integerValue+1)
                } else {
                    self.currentPin.flickrPage = 1
                } // if totalPages > self.currentPin.flickrPage.integerValue &&
                CoreDataManager.sharedInstance().saveContext()
                for (key, value) in URLArray! {
                    let dict = [Photo.Keys.ID: key, Photo.Keys.URL: value]
                    let photo = Photo(dictionary: dict, context: self.sharedContext)
                    photo.pin = self.currentPin
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if URLArray!.isEmpty {
                        self.newCollectionButton.enabled = true
                    }
                } // dispatch_async(dispatch_get_main_queue())
                */
                
                
                dispatch_async(dispatch_get_main_queue(), {
                
                if (totalPages > self.currentPin.flickrPage.integerValue) {
                    if (self.currentPin.flickrPage.integerValue <= self.totalPagesMax) {
                        self.currentPin.flickrPage = NSNumber(integer: self.currentPin.flickrPage.integerValue+1)
                    } else {
                        self.currentPin.flickrPage = 1
                    } // if (self.currentPin.flickrPage.integerValue <= self.totalPagesMax)
                } else {
                    self.currentPin.flickrPage = 1
                } // if totalPages > self.currentPin.flickrPage.integerValue &
                    dispatch_async(dispatch_get_main_queue(), {
                        CoreDataManager.sharedInstance().saveContext()
                    }) // dispatch_async(dispatch_get_main_queue()
                for (key, value) in URLArray! {
                    let dict = [Photo.Keys.ID: key, Photo.Keys.URL: value]
                    let photo = Photo(dictionary: dict, context: self.sharedContext)
                    photo.pin = self.currentPin
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if URLArray!.isEmpty {
                        self.newCollectionButton.enabled = true
                    }
                } // dispatch_async(dispatch_get_main_queue())
                    
                    
                }) // dispatch_async(dispatch_get_main_queue(),
                
            } // if let error = error
        }
    }
    
    // MARK: - UICollectionView DataSource / Delegate Implementation
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        configureCell(cell, photo: photo, indexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        _ = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        sharedContext.deleteObject(photo)
        //CoreDataManager.sharedInstance().saveContext()
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataManager.sharedInstance().saveContext()
        }) // dispatch_async(dispatch_get_main_queue()
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCell, photo: Photo, indexPath: NSIndexPath) {
        let placeHolderForImage = UIImage(named:"placeHolderForImage")
        cell.imageViewPhoto.image = placeHolderForImage
        switch photo.state {
        case Photo.PhotoRecordState.Failed.rawValue:
            cell.stopActivityIndicator()
            cell.imageViewPhoto.image = UIImage(named:"noImageAvailable")
        case Photo.PhotoRecordState.New.rawValue:
            cell.startActivityIndicator()
            self.startDownloadForRecord(photo, indexPath: indexPath)
        case Photo.PhotoRecordState.Downloaded.rawValue:
            if let image = photo.flickrImage {
                cell.imageViewPhoto.image = image
                cell.stopActivityIndicator()
            } else {
                if !photoCollection.dragging && !photoCollection.decelerating {
                    self.startDownloadForRecord(photo, indexPath: indexPath)
                }
            }
        default:
            self.displayOkAlertToUser("Error in configureCell: default action occured")
        }
    }
    
    // Downloader for all photos
    func startDownloadForRecord(photo: Photo, indexPath: NSIndexPath){
        dispatch_async(dispatch_get_main_queue(), {
        if let _ = self.pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        let downloader = photDownLoaderOperation(photoRecord: photo)
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                self.photoCollection.reloadItemsAtIndexPaths([indexPath])
            }) //dispatch_async(dispatch_get_main_queue(),
        }
        self.pendingOperations.downloadsInProgress[indexPath] = downloader
        self.pendingOperations.downloadQueue.addOperation(downloader)
            
        }) //dispatch_async(dispatch_get_main_queue()
    }
    
    
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        indexPathsThatWereInserted = [NSIndexPath]()
        indexPathsThatWereDeleted = [NSIndexPath]()
        indexPathsThatWereUpdated = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            indexPathsThatWereInserted.append(newIndexPath!) // object added
            break
        case .Delete:
            indexPathsThatWereDeleted.append(indexPath!) // object deleted
            break
        case .Update:
            indexPathsThatWereUpdated.append(indexPath!) // object updated
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        photoCollection.performBatchUpdates({() -> Void in
            for indexPath in self.indexPathsThatWereInserted {
                self.photoCollection.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.indexPathsThatWereDeleted {
                self.photoCollection.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.indexPathsThatWereUpdated {
                self.photoCollection.reloadItemsAtIndexPaths([indexPath])
            }
            }) { finished in
                // if all photos have been downloaded, re-enable button
                let pendingImages = self.fetchedResultsController.sections![0].objects as! [Photo]
                let results = pendingImages.filter() { (photo: Photo) in
                    return photo.flickrImage == nil
                }
                if results.count == 0 && !pendingImages.isEmpty {
                    self.newCollectionButton.enabled = true
                    self.photoCollection.allowsSelection = true
                }
        }
    }
    
    // MARK: - Configure The UI
    
    func configureUI() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.backItem?.title = "Tourist Map"
        self.navigationController?.toolbarHidden = false
        newCollectionButton = UIBarButtonItem(title: "New Collection", style: .Plain, target: self, action: #selector(PhotoAlbumViewController.addNewCollection(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        self.setToolbarItems([flexibleSpace, newCollectionButton, flexibleSpace], animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude), span)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.userInteractionEnabled = false
    }
    
    // MARK: - Display User Alert
    
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
