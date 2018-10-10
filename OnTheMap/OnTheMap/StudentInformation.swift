//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/27/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

import Foundation

struct StudentInformation {
    
/*  - Sample data from Parse data feed

    {"createdAt":"2016-02-06T18:58:31.394Z",
    "firstName":"Xavier",
    "lastName":"Jorda",
    "latitude":40.9746158",
    "longitude":0.5170919",
    "mapString":"Benifallet",
    "mediaURL":"Juju",
    "objectId":"VMtu3BDBhU",
    "uniqueKey":"2987668569",
    "updatedAt":"2016-02-06T18:58:31.394Z"
*/
    
    var createdAt: String
    var firstName: String
    var lastName: String
    var latitude: Float
    var longitude: Float
    var mapString: String
    var mediaURL: String
    var objectId: String
    var uniqueKey: String
    var updatedAt: String
    

    var description: String {
        return "StudentInformation: \(updatedAt): \(objectId)-\(uniqueKey)"
    }

    
    init( dictionary: [String : AnyObject] ) {
        createdAt = dictionary[ParseClient.JSONResponseKeys.createdAt] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.lastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.latitude] as! Float
        longitude = dictionary[ParseClient.JSONResponseKeys.longitude] as! Float
        mapString = dictionary[ParseClient.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.mediaURL] as! String
        objectId = dictionary[ParseClient.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.uniqueKey] as! String
        updatedAt = dictionary[ParseClient.JSONResponseKeys.updatedAt] as! String
    }
    
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var locations = [StudentInformation]()
        
        for result in results {
            locations.append( StudentInformation(dictionary: result) )
        }
        
        return locations
    }
    
}