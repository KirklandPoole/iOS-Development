//
//  Meme.swift
//  Meme1
//
//  Created by Kirkland Poole on 12/12/15.
//  Copyright © 2015 Kirkland Poole. All rights reserved.
//


import Foundation
import UIKit

struct Meme {
    var text1:String!
    var text2:String!
    var image:UIImage!
    var memedImage:UIImage!
    
    init(textString1: String!,
        textString2: String!,
        imageUIImage: UIImage!,
        memedImageUIImage: UIImage!) {
            text1 = textString1
            text2 = textString2
            image = imageUIImage
            memedImage = memedImageUIImage
    }
}

