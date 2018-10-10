//
//  MapSetttings.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import CoreData

@objc(MapSettings) // for Objective C modules

class MapSettings: NSManagedObject {
    
    @NSManaged var longitudeDelta: Double
    @NSManaged var latitudeDelta: Double
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    
    struct Keys {
        static let longitudeDelta = "lonΔ"
        static let latitudeDelta = "latΔ"
        static let longitude = "lon"
        static let latitude = "lat"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: Double], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("MapSettings", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        longitudeDelta = dictionary[Keys.longitudeDelta]!
        latitudeDelta = dictionary[Keys.latitudeDelta]!
        longitude = dictionary[Keys.longitude]!
        latitude = dictionary[Keys.latitude]!
    }
}
