//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 2/21/16.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

// References:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563
// http://stackoverflow.com/questions/32064295/nsmanagedobjectcontext-init-was-deprecated-in-ios-9-0-use-initwithconcu\
//

import Foundation
import CoreData

class CoreDataManager {
    
    class func sharedInstance() -> CoreDataManager {
        struct Static {
            static let inst = CoreDataManager()
        }
        return Static.inst
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "book.persistence.VirtualTourist" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("VirtualTourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    
    @objc func storeDidImportUbiquitousContentChanges(notification: NSNotification) {
        if let moc = self.managedObjectContext {
            moc.performBlock({ () -> Void in
                // Merge the content
                moc.mergeChangesFromContextDidSaveNotification(notification)
            })
            
            dispatch_async(dispatch_get_main_queue()) {
                // Refresh UI here
            }
        }
    }
    
    @objc func storeWillChange(notification: NSNotification) {
        if let moc = self.managedObjectContext {
            moc.performBlockAndWait({ () -> Void in
                var error: NSError?
                if (error == nil) {
                    error = nil
                }
                if moc.hasChanges {
                    do {
                        try moc.save()
                    } catch let error1 as NSError {
                        error = error1
                    } catch {
                        fatalError()
                    }
                }
                moc.reset()
            })
        }
    }
    
    @objc func storeDidChange(notification: NSNotification) {
        // At this point it's official, the change has happened. Tell your
        // user interface to refresh itself
        dispatch_async(dispatch_get_main_queue()) {
            NSFetchedResultsController.deleteCacheWithName("Master")
            // Refresh UI here
        }
    }

    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("VirtualTourist.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.storeWillChange(_:)),
                                       name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
                                       object: coordinator!)
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.storeDidChange(_:)),
                                       name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
                                       object: coordinator!)
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.storeDidImportUbiquitousContentChanges(_:)),
                                       name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
                                       object: coordinator!)
        
        let options = [NSPersistentStoreUbiquitousContentNameKey: "VirtualTourist"]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            //error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

