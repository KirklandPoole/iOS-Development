//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/30/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

// Refefences:
// http://stackoverflow.com/questions/32614235/binding-must-have-optional-type-swift
// http://stackoverflow.com/questions/24065536/downloading-and-parsing-json-in-swift
// https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSMutableURLRequest_Class/
// http://stackoverflow.com/questions/30816063/nsmutableurlrequest-httpbody-from-swift-array
//

import Foundation

class ParseClient: NSObject {
    
    static let sharedInstance = ParseClient()
    
    var locations: [StudentInformation]
    
    override init() {
        locations = [StudentInformation]()
        super.init()
    }
    
    func requestForMethod( method: String ) -> NSMutableURLRequest {
        let urlString = Constants.BaseURL
        let URL = NSURL(string: urlString)!
        return NSMutableURLRequest(URL: URL)
    }
    
    func taskWithRequest( request: NSMutableURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask {
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) { (data, response, error) in
            if error == nil {
                //Successful
                NetworkingUtility.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            } else {
                //There Was An Error
                completionHandler(results: nil, error: error)
            }
        }
        task.resume()
        return task
    }
    
    func getStudentLocations( completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        // Set sort Order by UpdateAt
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL + "?order=-updatedAt")!)
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    self.locations = StudentInformation.locationsFromResults(results)
                    completionHandler( success: true, errorMessage: Messages.downloadSuccessful )
                } else {
                    completionHandler( success: false, errorMessage: Messages.downloadError )
                }
            } else {
                completionHandler( success: false, errorMessage: Messages.networkError )
            }
        }
    }
    
    func queryStudentLocation( uniqueKey: String, completionHandler: (results: [StudentInformation]?, errorMessage: String?) -> Void ) {
        let urlString = "\(Constants.BaseURL)?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    let locations = StudentInformation.locationsFromResults(results)
                    completionHandler( results: locations, errorMessage: nil )
                }
            } else {
                completionHandler(results: nil, errorMessage: Messages.downloadError )
            }
        }
    }
    
    func postStudentLocation( data: [String : AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL)!)
        request.HTTPMethod = "POST"
        var jsonifyError: NSError?
        if (jsonifyError != nil) {
            jsonifyError = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.postError)
            }
        }
    }
    
    func putStudentLocation( objectId: String, data: [String: AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let urlString = "\(Constants.BaseURL)/\(objectId)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "PUT"
        var jsonifyError: NSError?
        if (jsonifyError != nil) {
            jsonifyError = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.postError)
            }
        }
    }
    
}