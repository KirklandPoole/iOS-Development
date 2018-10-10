//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/30/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//


import Foundation


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

extension ParseClient {
    struct Constants {
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let AppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let BaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct Messages {
        static let networkError = "Error connecting to remote server"
        static let downloadSuccessful = "Successful getting student data from server"
        static let downloadError = "Error getting student data from server"
        static let postError = "Error posting student informaton to server"
    }
    
    struct JSONResponseKeys {
        // Error
        static let error: String = "error"
        
        //Results
        static let results: String = "results"
        
        //POST
        static let createdAt: String = "createdAt"
        
        
        // Student data
        static let firstName: String = "firstName"
        static let lastName: String = "lastName"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let mapString: String = "mapString"
        static let mediaURL: String = "mediaURL"
        static let objectId: String = "objectId"
        static let uniqueKey: String = "uniqueKey"
        //PUT
        static let updatedAt: String = "updatedAt"
    }
}
