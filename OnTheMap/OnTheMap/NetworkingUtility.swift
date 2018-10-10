//
//  NetworkingUtility.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/29/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//
// References: 
// https://www.udacity.com/courses/ud421
// https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSJSONSerialization_Class/
//

import Foundation

class NetworkingUtility: NSObject {
    
    /* NetworkingUtility: If given a dictionary of parameters, convert to a string for a URL */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVariables = [String]()
        for (key, value) in parameters {
            //
            /* Is this a string value? */
            let stringValue = "\(value)"
            /* Escape */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append */
            urlVariables += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVariables.isEmpty ? "?" : "") + urlVariables.joinWithSeparator("&")
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var errorWhileParsing: NSError? = nil
        let resultFromParsing: AnyObject?
        do {
            resultFromParsing = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            errorWhileParsing = error
            resultFromParsing = nil
        }
        if let error = errorWhileParsing {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: resultFromParsing, error: nil)
        }
    }
    
}

