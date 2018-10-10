//
//  SentMemeTableViewController.swift
//  Meme1
//
//  Created by Kirkland Poole on 12/13/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

import UIKit

class SentMemeTableViewController: UITableViewController {
    
    // Mark: main data source
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    // MARK: -  View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(animated: Bool) {
            setTabBarVisible(true, animated: false)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)

        let meme = memes[indexPath.row]
        
        cell.textLabel?.text = meme.text1 + "..." +  meme.text2
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        if let indexPath = tableView.indexPathForSelectedRow {
           let detailViewController =  storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
            let meme = memes[indexPath.row]
            detailViewController.detailItem = meme
            if (tabBarIsVisible()) {
                setTabBarVisible(false, animated: false)
            }
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    
/*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } 
    }
*/
    
    
    // MARK: - Hide / Unhide Tab Bars
    func setTabBarVisible(visible:Bool, animated:Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(view.frame)
    }
    

}
