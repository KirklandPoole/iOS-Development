//
//  PhotoOperations.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563
// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSOperation_class/
// https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift

import UIKit

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath: NSOperation]()
    // NSOperation queue to process flickr photos
    lazy var downloadQueue: NSOperationQueue = {
        var operationQueue = NSOperationQueue()
        operationQueue.name = "Queue_For_Photo_Downloading"
        return operationQueue
    }()
}

//  Class for photo downloading
class photDownLoaderOperation: NSOperation {
    let photoRecord: Photo
    init(photoRecord: Photo) {
        self.photoRecord = photoRecord
    }
    
    
    override func main() {
        if self.cancelled {
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            if (self.photoRecord.url.characters.count > 0) {
                if let imageData = NSData(contentsOfURL: NSURL(string: self.photoRecord.url)!) {
                    if imageData.length > 0 {
                            self.photoRecord.flickrImage = UIImage(data:imageData)
                        } else {
                            self.photoRecord.state = Photo.PhotoRecordState.Failed.rawValue
                        }
                }
            }
        } // dispatch_async(dispatch_get_main_queue())
        if self.cancelled {
            return
        }
    }
}
