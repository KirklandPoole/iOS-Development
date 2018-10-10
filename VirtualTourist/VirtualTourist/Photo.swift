//
//  Photo.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import UIKit
import CoreData

@objc(Photo) // for Objective C modules

class Photo: NSManagedObject {
    @NSManaged var id           : String
    @NSManaged var url          : String
    @NSManaged var state        : NSNumber
    @NSManaged var pin          : Pin
    
    struct Keys {
        static let ID        = "id"
        static let URL       = "url_m"
    }
    
    
    // Define possible states for photo, new, downloaed, failed
    enum PhotoRecordState: Int {
        case New = 0, Downloaded, Failed
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: String], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        id = dictionary[Keys.ID]!
        url = dictionary[Keys.URL]!
        if let existedImage = GetDataFromFlicker.Caches.imageCache.imageWithIdentifier(id) {
            dispatch_async(dispatch_get_main_queue()) {
            self.flickrImage = existedImage
            self.state = PhotoRecordState.Downloaded.rawValue
            }
        }
    }
    
    var flickrImage: UIImage? = nil {
        didSet {
                if flickrImage == nil {
                    state = PhotoRecordState.New.rawValue
                } else {
                    GetDataFromFlicker.Caches.imageCache.storeImage(flickrImage, withIdentifier: id)
                    state = PhotoRecordState.Downloaded.rawValue
                } // if flickrImage == nil
            }
    }
    
    // Prepare for deletion of photo object from imagecache
    override func prepareForDeletion() {
        super.prepareForDeletion()
        GetDataFromFlicker.Caches.imageCache.storeImage(nil, withIdentifier: id)
    }
}
