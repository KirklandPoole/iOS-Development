//
//  GetDataFromFlicker.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import Foundation

class GetDataFromFlicker: NetworkingUtilities {
    
    // MARK: - Constants, JSONResponseKeys and ParameterKeys Defined
    
    struct Constants {
        static let APIKey = "7ce875c73407676902a4d025c6186646"
        static let BaseURL = "https://api.flickr.com/services/rest/"
        static let URLM = "url_m"
        static let MethodName = "flickr.photos.search"
        static let ResultsPerPage = 15
        static let DataFormat = "json"
        static let NoJSONCallback = "1"
    }
    
    struct JSONResponseKeys {
        static let PhotoID = "id"
        static let PhotoURL = "url_m"
        static let Photo = "photo"
        static let Photos = "photos"
        static let PhotoTitle = "title"
        static let PhotoPagesTotal = "pages"
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let Method = "method"
        static let Longitude = "lon"
        static let Latitude = "lat"
        static let PageNumber = "page"
        static let ResultsPerPage = "per_page"
        static let Extras = "extras"
        static let DataFormat = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    
    // MARK: - Cache for Images
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Singleton: sharedInstance() -> GetDataFromFlicker
    
    class func sharedInstance() -> GetDataFromFlicker {
        struct Singleton {
            static var sharedInstance = GetDataFromFlicker()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Search Function
    
    func searchPhotosWithLatitudeAndLangitude(latitude: Double, longitude: Double, pageNumber: Int, completionHandler: (URLArray: [String: String]?, error: String?, totalPages: Int?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.Method: Constants.MethodName,
            ParameterKeys.APIKey: Constants.APIKey,
            ParameterKeys.Extras: Constants.URLM,
            ParameterKeys.DataFormat: Constants.DataFormat,
            ParameterKeys.NoJSONCallback: Constants.NoJSONCallback,
            ParameterKeys.Latitude: latitude,
            ParameterKeys.Longitude: longitude,
            ParameterKeys.ResultsPerPage: Constants.ResultsPerPage,
            ParameterKeys.PageNumber: pageNumber
        ]
        let baseURLWithEscapedParameters = Constants.BaseURL + escapedParameters(parameters)
        getDataTaskRequest(baseURLWithEscapedParameters) { JSONResult, error in
            if let error = error {
                completionHandler(URLArray: nil, error: "\(error.domain): \(error.localizedDescription)", totalPages: nil)
            } else {
                if let photosDictionary = JSONResult.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject] {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if let totalPages = photosDictionary[JSONResponseKeys.PhotoPagesTotal] as? Int {
                            if let arrayOfPhotos = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] {
                                var arrayForURL = [String: String]()
                                for photo in arrayOfPhotos {
                                    arrayForURL[(photo["id"] as? String)!] = (photo["url_m"] as? String)!
                                }
                                completionHandler(URLArray: arrayForURL, error: nil, totalPages: totalPages)
                            } else {
                                completionHandler(URLArray: nil, error: "No key found for \(JSONResponseKeys.Photo) in \(photosDictionary)", totalPages: nil)
                            }
                        } else {
                            completionHandler(URLArray: nil, error: "No key found for \(JSONResponseKeys.PhotoPagesTotal) in \(photosDictionary)", totalPages: nil)
                        }
                    }) // dispatch_async(dispatch_get_main_queue()
                    
                } else {
                    completionHandler(URLArray: nil, error: "No key found for \(JSONResponseKeys.Photos) in \(JSONResult)", totalPages: nil)
                }
            }
        }
    }
    
    // MARK: - Task For Image
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        return task
    }
}
