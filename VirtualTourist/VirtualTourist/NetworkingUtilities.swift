//
//  NetworkingUtilities.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import Foundation

class NetworkingUtilities: NSObject {
    
    // shared session for NSURLSession
    var session: NSURLSession
    
    // Init()
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - getDataTaskRequest
    
    func getDataTaskRequest(URLString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // building URL and configuring the request
        let url = NSURL(string: URLString)!
        let request = NSURLRequest(URL: url)
        
        // request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            // parsing
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                NetworkingUtilities.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        // start the request
        task.resume()
        return task
    }
    
    // MARK: - JSON Helpers
    
    // convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // Convert JSON data to a Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
}
