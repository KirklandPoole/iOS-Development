//
//  SentMemeCollectionViewController.swift
//  Meme1
//
//  Created by Kirkland Poole on 12/13/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SentMemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - main data source
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    
    override func viewWillAppear(animated: Bool) {
        collectionView!.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
    
        cell.memeImageView.image = memes[indexPath.row].memedImage
    
        return cell
    }

    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let detailViewController =  storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
            let meme = memes[indexPath.row]
            detailViewController.detailItem = meme
            navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
}
    
     // MARK: - Class for CollectionViewCell

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var memeImageView: UIImageView!
}
