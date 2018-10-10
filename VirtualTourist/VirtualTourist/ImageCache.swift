//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import UIKit

class ImageCache {
    private var activeCache = NSCache() // cache for in memory objects
    
    // MARK: - Get images using identifier
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        // Handle identifier is nil, or empty
        if identifier == nil || identifier! == "" {
            return nil
        }
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        if (data != nil) {
            data = nil
        } else {
        }
        // Search active cache
        if let image = activeCache.objectForKey(path) as? UIImage {
            return image
        }        // Search documents directory
        if let imageAsNSData = NSData(contentsOfFile: path) {
            return UIImage(data: imageAsNSData)
        }
        // Image Not Found anywhere so return nil
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        // If the image is nil, remove images from active cache
        if image == nil {
            activeCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {}
            return
        }
        // Otherwise, put the image in active cache
        activeCache.setObject(image!, forKey: path)
        // Write image to documents directory
        let imageInPNGFormat = UIImagePNGRepresentation(image!)
        imageInPNGFormat!.writeToFile(path, atomically: true)
    }
    
    // MARK: - Get URL to image in Documents directory
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(identifier)
        return fileURL.path!
    }
    
}
