//
//  PrizeValueViewController.swift
//  LottoMagic
//
//  Created by Kirkland Poole on 3/29/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//


import UIKit
import CoreData

class PrizeValueViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfFetchedObjects : Int = (self.fetchedResultsController.fetchedObjects?.count)!
        if (numberOfFetchedObjects == 0) {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            activityIndicator.backgroundColor = UIColor.blackColor()
            loadPrizeValueFromLocalJSONDataFile()
            tableView.reloadData()
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Mark: - Actions
    
    func loadPrizeValueFromLocalJSONDataFile() {
        let jsonURL = NSBundle.mainBundle().URLForResource("PrizeLevel", withExtension: "json")!
        let jsonData = NSData(contentsOfURL: jsonURL)
        // Parse the data (i.e. convert the data to JSON and look for values!)
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments)
        } catch {
            parsedResult = nil
            //Could not parse the data as JSON
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Could not parse the PrizeValue data as JSON", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
        }
        /* GUARD: convert to an array */
        guard let prizeValueArray = parsedResult as? NSArray else {
            //Cannot let prizeValueArray = parsedResult
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertController(title: "Error", message: "Cannot convert data to prizeValueArray from parse result", preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alert.addAction(dismissAlert)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        // Inserts attributes for database
        let entity = NSEntityDescription.entityForName("PrizeValue", inManagedObjectContext: self.managedObjectContext)!
        for jsonDictionary in prizeValueArray {
            // listing of columns in JSON seed file
            let gameId = jsonDictionary.valueForKey("gameId") as! String
            let prizeValueId = jsonDictionary.valueForKey("prizeLevelId") as! String
            let prizeLevelValue = jsonDictionary.valueForKey("prizeLevelValue") as! String
            let standardBallsMatched = jsonDictionary.valueForKey("standardBallsMatched") as! String
            let bonusBallsMatched = jsonDictionary.valueForKey("bonusBallsMatched") as! String
            
            
            let prizeValue = PrizeValue(entity: entity, insertIntoManagedObjectContext:self.managedObjectContext)
            
            if let gameIdInt = Int(gameId) {
                let gameIdNumber = NSNumber(integer:gameIdInt)
                prizeValue.gameId = gameIdNumber
            } else {
               //(gameId) did not convert to an Int
            } // if let gameIdInt = Int(gameId)
            if let prizeValueIdInt = Int(prizeValueId) {
                let prizeValueIdNumber = NSNumber(integer:prizeValueIdInt)
                prizeValue.prizeValueId = prizeValueIdNumber
            } else {
                //(prizeValueId) did not convert to an Int
            } // if let prizeValueIdInt = Int(prizeValueId)
            
            if let prizeLevelValueInt = Int(prizeLevelValue) {
                let prizeLevelValueNumber = NSNumber(integer:prizeLevelValueInt)
                prizeValue.prizeLevelValue = prizeLevelValueNumber
            } else {
                //(prizeLevelValue) did not convert to an Int
            } // if let prizeLevelValueInt = Int(prizeLevelValue)
            
            if let standardBallsMatchedInt = Int(standardBallsMatched) {
                let standardBallsMatchedNumber = NSNumber(integer:standardBallsMatchedInt)
                prizeValue.standardBallsMatched = standardBallsMatchedNumber
            } else {
                //standardBallsMatched)' did not convert to an Int
            } // if let standardBallsMatchedInt = Int(standardBallsMatched)
            
            if let bonusBallsMatchedInt = Int(bonusBallsMatched) {
                let bonusBallsMatchedNumber = NSNumber(integer:bonusBallsMatchedInt)
                prizeValue.bonusBallsMatched = bonusBallsMatchedNumber
            } else {
                //(bonusBallsMatched)' did not convert to an Int
            } // if let bonusBallsMatchedInt = Int(bonusBallsMatched)
            
        } // for jsonDictionary in jsonArray
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        let CellIdentifier = "PrizeValueCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! PrizeValueViewCell
        cell.standardBallsMatchedLabel.text = object.valueForKey("standardBallsMatched")!.description
        cell.bonusBallsMatchedLabel.text = object.valueForKey("bonusBallsMatched")!.description
        if (indexPath.row > 0) {
            let prizeValue = object.valueForKey("prizeLevelValue") as! NSNumber
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            
            formatter.locale = NSLocale.currentLocale()
            //formatter.locale = NSLocale(localeIdentifier: "es_CL")
            cell.jackpotImage.hidden = true
            //cell.prizeValueLabel.text = object.valueForKey("prizeLevelValue")!.description
            cell.prizeValueLabel.text = formatter.stringFromNumber(prizeValue)
        } else {
            cell.jackpotImage.hidden = false
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("PrizeValue", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "prizeValueId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "PrizeValueViewController")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Reload PrizeValue - reloadData()
    
    func reLoadPrizeValue() {
        self.tableView.reloadData()
    }
}

































