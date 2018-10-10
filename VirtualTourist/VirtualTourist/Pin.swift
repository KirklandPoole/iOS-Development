//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563
// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html
//

import CoreData

@objc(Pin) // for Objective C modules

class Pin: NSManagedObject {
    
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var flickrPage: NSNumber
    @NSManaged var photos: [Photo]
    
    struct Keys {
        static let Longitude = "lon"
        static let Latitude = "lat"
        static let FlickrPage = "page"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        flickrPage = 1
    }
    
    init(dictionary:[String: Double], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        longitude = dictionary[Keys.Longitude]!
        latitude = dictionary[Keys.Latitude]!
    }
}
