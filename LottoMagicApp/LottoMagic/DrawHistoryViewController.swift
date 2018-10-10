//
//  DrawHistoryViewController.swift
//  LottoMagic
//
//  Created by Kirkland Poole on 3/24/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

import UIKit
import CoreData




class DrawHistoryViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControlUI2 : UIRefreshControl!
    
    let dateFormatter = NSDateFormatter()
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        refreshControlUI2 = UIRefreshControl()
        refreshControlUI2.addTarget(self, action: #selector(DrawHistoryViewController.reLoadDrawHistory), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControlUI2)
        let numberOfFetchedObjects : Int = (self.fetchedResultsController.fetchedObjects?.count)!
        if (numberOfFetchedObjects == 0) {
            // Check For Reachability
            if Reachability.isConnectedToNetwork() == true {
                loadDrawHistoryFromJSON()
                tableView.reloadData()
            } else {
                // Handle the error case
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Network Error: Internet connection FAILED", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } // if Reachability.isConnectedToNetwork() == true
        }
        if self.activityIndicator.isAnimating() {
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
            } // dispatch_async(dispatch_get_main_queue())
        } // if self.activityIndicator.isAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Mark: - Actions
    

    
    func loadDrawHistoryFromJSON() {
        
        let resource = LotteryDB.Constants.BaseUrl
        _ = LotteryDB.sharedInstance().taskForResource(resource) { [unowned self] jsonResult, error in
            // Activity Indicator
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.startAnimating()
            } // dispatch_async(dispatch_get_main_queue())
            
            // Handle the error case
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Network Error: Unable to access endpoint API", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            }
            
            // Get a Swift dictionary from the JSON data
            if let drawHistoryArray = jsonResult as? [[String : AnyObject]] {
                
                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //"yyyy-MM-dd"
                let RFC3339DateFormatter = NSDateFormatter()
                RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                
                var drawDictionary : NSDictionary
                for (index, _) in drawHistoryArray.enumerate() {
                    //let drawDictionary = drawHistoryArray[index] as? NSDictionary
                    drawDictionary = drawHistoryArray[index]
                    let drawDateFromDictionary = drawDictionary["draw_date"] as? String /* non-fatal */
                    let winningNumbers = drawDictionary["winning_numbers"] as? String /* non-fatal */
                    if let theWinningNumbers = winningNumbers {
                        if ( (!drawDateFromDictionary!.isEmpty) && (!theWinningNumbers.isEmpty) ) {
                            // Parsing stated...
                            let drawDateRange = NSMakeRange(0, 10)
                            let theDrawDate = (drawDateFromDictionary! as NSString).substringWithRange(drawDateRange) + "T02:59:00-05:00"
                            // Parse Balls
                            //01234567890123456
                            //21 31 64 65 67 05 // b1...b5...bonusBall
                            let b1Range = NSMakeRange(0, 2)
                            let b2Range = NSMakeRange(3, 2)
                            let b3Range = NSMakeRange(6, 2)
                            let b4Range = NSMakeRange(9, 2)
                            let b5Range = NSMakeRange(12, 2)
                            let bonusBallRange = NSMakeRange(15, 2)
                            //Parsing finised.
                            // Start of drawDate formatting...
                            // Example RFC3339DateFormat = "1996-12-19T16:39:57-08:00"
                            if let date = RFC3339DateFormatter.dateFromString(theDrawDate) {
                                if let dateOfLastFormatChange = RFC3339DateFormatter.dateFromString("2015-10-04T00:00:00Z") {
                                    let compareResult = dateOfLastFormatChange.compare(date)
                                    if ( (compareResult == NSComparisonResult.OrderedAscending) || (compareResult == NSComparisonResult.OrderedSame)  ) {
                                        // Update core data starting...
                                        let newDrawHistory = NSEntityDescription.insertNewObjectForEntityForName("DrawHistory",inManagedObjectContext:self.managedObjectContext) as NSManagedObject
                                        // DrawDate
                                        newDrawHistory.setValue(date, forKey: "drawDate")
                                        // b1
                                        let newB1String = (theWinningNumbers as NSString).substringWithRange(b1Range)
                                        if let newB1Int = Int(newB1String) {
                                            let b1Number = NSNumber(integer:newB1Int)
                                            newDrawHistory.setValue(b1Number, forKey: "b1")
                                        } // if let newB1Int = Int(newB1String)
                                        
                                        // b2
                                        let newB2String = (theWinningNumbers as NSString).substringWithRange(b2Range)
                                        if let newB2Int = Int(newB2String) {
                                            let b2Number = NSNumber(integer:newB2Int)
                                            newDrawHistory.setValue(b2Number, forKey: "b2")
                                        } // if let newB2Int = Int(newB2String)
                                        // b3
                                        let newB3String = (theWinningNumbers as NSString).substringWithRange(b3Range)
                                        if let newB3Int = Int(newB3String) {
                                            let b3Number = NSNumber(integer:newB3Int)
                                            newDrawHistory.setValue(b3Number, forKey: "b3")
                                        } // if let newB3Int = Int(newB3String)
                                        // b4
                                        let newB4String = (theWinningNumbers as NSString).substringWithRange(b4Range)
                                        if let newB4Int = Int(newB4String) {
                                            let b4Number = NSNumber(integer:newB4Int)
                                            newDrawHistory.setValue(b4Number, forKey: "b4")
                                        } // if let newB4Int = Int(newB4String)
                                        // b5
                                        let newB5String = (theWinningNumbers as NSString).substringWithRange(b5Range)
                                        if let newB5Int = Int(newB5String) {
                                            let b5Number = NSNumber(integer:newB5Int)
                                            newDrawHistory.setValue(b5Number, forKey: "b5")
                                        } // if let newB5Int = Int(newB5String)
                                        // bonusBall
                                        let newBonusBallString = (theWinningNumbers as NSString).substringWithRange(bonusBallRange)
                                        if let newBonusBallInt = Int(newBonusBallString) {
                                            let bonusBallNumber = NSNumber(integer:newBonusBallInt)
                                            newDrawHistory.setValue(bonusBallNumber, forKey: "bonusBall")
                                        } // if let newBonusBallInt = Int(newBonusBallString)
                                        // Save the context.
                                        do {
                                            try self.managedObjectContext.save()
                                        } catch {
                                            abort()
                                        } // do
                                    } // if ( (compareResult == NSComparisonResult.OrderedAscending) || (compareResult == NSComparisonResult.OrderedSame)  )
                                } // if let dateOfLastFormatChange = RFC3339DateFormatter.dateFromString("2015-10-04T00:00:00Z")
                            } // if let date = RFC3339DateFormatter.dateFromString(theDrawDate)
                            //End of drawDate formatting.
                        } // if !theWinningNumbers.isEmpty
                    } // if let theWinningNumbers = winningNumbers
                } // for (index, _) in drawHistoryArray.enumerate()
                if self.activityIndicator.isAnimating() {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                    } // dispatch_async(dispatch_get_main_queue())
                } // if self.activityIndicator.isAnimating()
                
                // Reload the table on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView!.reloadData()
                }
            }
        }
        if self.activityIndicator.isAnimating() {
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
            } // dispatch_async(dispatch_get_main_queue())
        } // if self.activityIndicator.isAnimating()
    }
    
    
    func xloadDrawHistoryFromJSON() {
        // Initialize session and url
        let session = NSURLSession.sharedSession()
        let BASE_URL = "http://data.ny.gov/resource/d6yy-54nr.json"
        let urlString = BASE_URL
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        // Initialize task for getting data
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Activity Indicator
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.startAnimating()
            } // dispatch_async(dispatch_get_main_queue())
            //Check for a successful response
            // GUARD: Was there an error?
            guard (error == nil) else {
                // Handle the error case
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "Error", message: "Network Error: Unable to access endpoint API", preferredStyle: UIAlertControllerStyle.Alert)
                        let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alert.addAction(dismissAlert)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
            } // guard (error == nil) else
            //  GUARD: Was there any data returned?
            guard let data = data else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "No data was returned by the request.", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            } // guard let data = data else
            //Parse the data (i.e. convert the data to JSON and look for values!)
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Could not parse the data as JSON:", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            }
            // GUARD: convert to an array
            guard let drawHistoryArray = parsedResult as? NSArray else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Cannot let drawHistoryArray = parsedResult", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAlert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            }
            self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //"yyyy-MM-dd"
            let RFC3339DateFormatter = NSDateFormatter()
            RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            
            for (index, _) in drawHistoryArray.enumerate() {
                let drawDictionary = drawHistoryArray[index] as? NSDictionary
                let drawDateFromDictionary = drawDictionary!["draw_date"] as? String /* non-fatal */
                //let multiplier = drawDictionary!["multiplier"] as? String /* non-fatal */
                let winningNumbers = drawDictionary!["winning_numbers"] as? String /* non-fatal */
                if let theWinningNumbers = winningNumbers {
                    if ( (!drawDateFromDictionary!.isEmpty) && (!theWinningNumbers.isEmpty) ) {
                       // Parsing stated...
                        let drawDateRange = NSMakeRange(0, 10)
                        let theDrawDate = (drawDateFromDictionary! as NSString).substringWithRange(drawDateRange) + "T02:59:00-05:00"
                        // Parse Balls
                        //01234567890123456
                        //21 31 64 65 67 05 // b1...b5...bonusBall
                        let b1Range = NSMakeRange(0, 2)
                        let b2Range = NSMakeRange(3, 2)
                        let b3Range = NSMakeRange(6, 2)
                        let b4Range = NSMakeRange(9, 2)
                        let b5Range = NSMakeRange(12, 2)
                        let bonusBallRange = NSMakeRange(15, 2)
                        //Parsing finised.
                        // Start of drawDate formatting...
                        // Example RFC3339DateFormat = "1996-12-19T16:39:57-08:00"
                        if let date = RFC3339DateFormatter.dateFromString(theDrawDate) {
                            if let dateOfLastFormatChange = RFC3339DateFormatter.dateFromString("2015-10-04T00:00:00Z") {
                                let compareResult = dateOfLastFormatChange.compare(date)
                                if ( (compareResult == NSComparisonResult.OrderedAscending) || (compareResult == NSComparisonResult.OrderedSame)  ) {
                                    // Update core data starting...
                                    let newDrawHistory = NSEntityDescription.insertNewObjectForEntityForName("DrawHistory",inManagedObjectContext:self.managedObjectContext) as NSManagedObject
                                    // DrawDate
                                    newDrawHistory.setValue(date, forKey: "drawDate")
                                    // b1
                                    let newB1String = (theWinningNumbers as NSString).substringWithRange(b1Range)
                                    if let newB1Int = Int(newB1String) {
                                        let b1Number = NSNumber(integer:newB1Int)
                                            newDrawHistory.setValue(b1Number, forKey: "b1")
                                    } // if let newB1Int = Int(newB1String)
                                    
                                    // b2
                                    let newB2String = (theWinningNumbers as NSString).substringWithRange(b2Range)
                                    if let newB2Int = Int(newB2String) {
                                        let b2Number = NSNumber(integer:newB2Int)
                                        newDrawHistory.setValue(b2Number, forKey: "b2")
                                    } // if let newB2Int = Int(newB2String)
                                    // b3
                                    let newB3String = (theWinningNumbers as NSString).substringWithRange(b3Range)
                                    if let newB3Int = Int(newB3String) {
                                        let b3Number = NSNumber(integer:newB3Int)
                                        newDrawHistory.setValue(b3Number, forKey: "b3")
                                    } // if let newB3Int = Int(newB3String)
                                    // b4
                                    let newB4String = (theWinningNumbers as NSString).substringWithRange(b4Range)
                                    if let newB4Int = Int(newB4String) {
                                        let b4Number = NSNumber(integer:newB4Int)
                                        newDrawHistory.setValue(b4Number, forKey: "b4")
                                    } // if let newB4Int = Int(newB4String)
                                    // b5
                                    let newB5String = (theWinningNumbers as NSString).substringWithRange(b5Range)
                                    if let newB5Int = Int(newB5String) {
                                        let b5Number = NSNumber(integer:newB5Int)
                                        newDrawHistory.setValue(b5Number, forKey: "b5")
                                    } // if let newB5Int = Int(newB5String)
                                    // bonusBall
                                    let newBonusBallString = (theWinningNumbers as NSString).substringWithRange(bonusBallRange)
                                    if let newBonusBallInt = Int(newBonusBallString) {
                                        let bonusBallNumber = NSNumber(integer:newBonusBallInt)
                                        newDrawHistory.setValue(bonusBallNumber, forKey: "bonusBall")
                                    } // if let newBonusBallInt = Int(newBonusBallString)
                                    // Save the context.
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        abort()
                                    } // do
                                } // if ( (compareResult == NSComparisonResult.OrderedAscending) || (compareResult == NSComparisonResult.OrderedSame)  )
                            } // if let dateOfLastFormatChange = RFC3339DateFormatter.dateFromString("2015-10-04T00:00:00Z")
                        } // if let date = RFC3339DateFormatter.dateFromString(theDrawDate)
                        //End of drawDate formatting.
                    } // if !theWinningNumbers.isEmpty
                } // if let theWinningNumbers = winningNumbers
            }
            if self.activityIndicator.isAnimating() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                } // dispatch_async(dispatch_get_main_queue())
            } // if self.activityIndicator.isAnimating()
        } // let task = session.dataTaskWithRequest(request) { (data, response, error) in
        // Resume (execute) the task
        task.resume()
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
        let CellIdentifier = "DrawHistoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! DrawHistoryTableViewCell
        if let _theDate = object.valueForKey("drawDate") as? NSDate {
            dateFormatter.dateStyle = .MediumStyle
            let drawDateAsAString = dateFormatter.stringFromDate(_theDate)
            // drawDate
            cell.drawDateLabel!.text = drawDateAsAString
            // b1
            if let b1 = object.valueForKey("b1") as? NSNumber {
                cell.b1Label!.text = b1.description
            } // if let b1 = object.valueForKey("b1") as? NSNumber
            // b2
            if let b2 = object.valueForKey("b2") as? NSNumber {
                cell.b2Label!.text = b2.description
            } // if let b2 = object.valueForKey("b2") as? NSNumber
            // b3
            if let b3 = object.valueForKey("b3") as? NSNumber {
                cell.b3Label!.text = b3.description
            } // if let b3 = object.valueForKey("b3") as? NSNumber
            // b4
            if let b4 = object.valueForKey("b4") as? NSNumber {
                cell.b4Label!.text = b4.description
            } // if let b4 = object.valueForKey("b4") as? NSNumber
            // b5
            if let b5 = object.valueForKey("b5") as? NSNumber {
                cell.b5Label!.text = b5.description
            } // if let b5 = object.valueForKey("b5") as? NSNumber
            // bonusBall
            if let bonusBall = object.valueForKey("bonusBall") as? NSNumber {
                cell.bonusBallLabel!.text = bonusBall.description
            } // if let bonusBall = object.valueForKey("bonusBall") as? NSNumber
        } // if let _theDate = object.valueForKey("drawDate") as? NSDate
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PrizeValueViewController") as! PrizeValueViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("DrawHistory", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "drawDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "DrawHistoryViewController")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        return _fetchedResultsController!
    }
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
    
    
    // MARK: - Reload DrawHistory - reloadData()
    
    func reLoadDrawHistory() {
        // Check For Reachability
        if Reachability.isConnectedToNetwork() == true {
            self.navigationItem.rightBarButtonItem?.enabled = false
            deleteDrawHistoryData()
            loadDrawHistoryFromJSON()
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem?.enabled = true
            //Activity Indicator
            if self.activityIndicator.isAnimating() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                } // dispatch_async(dispatch_get_main_queue())
            } // if self.activityIndicator.isAnimating()
            self.refreshControlUI2!.endRefreshing()
        } else {
            // Handle the error case
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertController(title: "Error", message: "Network Error: Internet connection FAILED", preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAlert = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alert.addAction(dismissAlert)
                self.presentViewController(alert, animated: true, completion: nil)
            }  // dispatch_async(dispatch_get_main_queue())
            self.refreshControlUI2!.endRefreshing()
            return
        } // if Reachability.isConnectedToNetwork() == true
    }
    
    
    // MARK: - Purge DrawHistory
    func deleteDrawHistoryData() {
        let request = NSFetchRequest(entityName: "DrawHistory")
        let arr = try! self.managedObjectContext.executeFetchRequest(request)
        for item in arr {
            self.managedObjectContext.deleteObject(item as! NSManagedObject)
            try! self.managedObjectContext.save()
        }
    }
 
}
































