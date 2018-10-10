//
//  DetailViewController.swift
//  MemeTestAppMasterDetail
//
//  Created by Kirkland Poole on 12/15/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Get current meme image from selected tableView for CollectonView item
    var detailItem: Meme? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
    // MARK: - Configure the view to show the current meme image
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let viewImage = imageView {
                viewImage.image = detail.memedImage
            }
        }
    }
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

}

