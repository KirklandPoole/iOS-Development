//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Kirkland Poole on 12/10/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//
//
// Reference:
// This application is modeled after the Favorite Actor app: https://www.udacity.com/course/viewer#!/c-ud325-nd/l-3648658724/m-3748298563

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    func startActivityIndicator() {
            activityIndicator.alpha = 1.0
            activityIndicator.startAnimating()
    }
    
    
    func stopActivityIndicator() {
        activityIndicator.alpha = 0.0
        activityIndicator.stopAnimating()
    }
}
