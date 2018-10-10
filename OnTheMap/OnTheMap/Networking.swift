//
//  Networking.swift
//  OnTheMap
//
//  Created by Kirkland Poole on 1/27/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

import Foundation




class Networking: NSObject {
    
    
    
    //Singleton
    static let sharedInstance = Networking()
    
    var userID: String?
    var name: Name?
    
    struct Name {
        var first = ""
        var last = ""
        var fullname: String {
            return "\(first) \(last)"
        }
    }
    
    struct Constants {
        static let BaseURL : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let User = "users/"
    }
    
    struct Messages {
        static let loginError = "Login failed - Incorrect credentails (wrong email or password"
        static let networkError = "Connection Failure - Failure to connect to network"
    }
    
    override init() {
        super.init()
    }
    
    func requestForMethod( method: String ) -> NSMutableURLRequest {
        let urlString = Constants.BaseURL + method
        let URL = NSURL(string: urlString)!
        
        return NSMutableURLRequest(URL: URL)
    }
    
    func taskWithRequest( request: NSURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) { (data, response, error) in
            if error == nil {
                //Success
                let trimmedData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                NetworkingUtility.parseJSONWithCompletionHandler(trimmedData, completionHandler: completionHandler)
            } else {
                //Error
                completionHandler(results: nil, error: error)
            }
        }
        task.resume()
        return task
    }
    
    
    func loginWithUsernamePassword(username: String, password: String, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = requestForMethod(Methods.Session)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskWithRequest( request ) { result, error in
            if error == nil {
                if let account = result!.valueForKey("account") as? NSDictionary {
                    if let userID = account.valueForKey("key") as? String {
                        self.userID = userID
                        self.getUserData( userID ) { success, errorMessage in
                            if( success ) {
                            } else {
                                print( "Error: \(errorMessage)" )
                            }
                        }
                        
                        completionHandler(success: true, errorMessage: nil)
                    } else {
                        completionHandler(success: false, errorMessage: Messages.loginError)
                    }
                } else {
                    completionHandler(success: false, errorMessage: Messages.loginError)
                }
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
    }
   
 
    func logout( completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let request = requestForMethod(Methods.Session)
        request.HTTPMethod = "DELETE"
        
        let cookies:[NSHTTPCookie] = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! as [NSHTTPCookie]
        var xsrfCookie: NSHTTPCookie? = nil
        for cookie:NSHTTPCookie in cookies as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskWithRequest(request) { result, error in
            if error == nil {
                self.userID = nil
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
    }
    
    
    func getUserData(userID: String, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = requestForMethod(Methods.User + userID)
        request.HTTPMethod = "GET"
        
        taskWithRequest(request) { result, error in
            if error == nil {
                if let user = result!.valueForKey("user") as? NSDictionary {
                    self.name = Name()
                    
                    if let last_name = user.valueForKey("last_name") as? String{
                        self.name?.last = last_name
                    }
                    
                    if let first_name = user.valueForKey("first_name") as? String{
                        self.name?.first = first_name
                    }
                    completionHandler(success: true, errorMessage: nil)
                }
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
        
    }
    
    
}
