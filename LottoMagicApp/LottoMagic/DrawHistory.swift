//
//  DrawHistory.swift
//  LottoMagic
//
//  Created by Kirkland Poole on 3/28/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

import UIKit
import CoreData

class DrawHistory: NSManagedObject {
    @NSManaged var gameId: NSNumber
    @NSManaged var drawHistoryId: NSNumber
    @NSManaged var drawDate: NSDate?
    @NSManaged var b1: NSNumber
    @NSManaged var b2: NSNumber
    @NSManaged var b3: NSNumber
    @NSManaged var b4: NSNumber
    @NSManaged var b5: NSNumber
    @NSManaged var bonusBall: NSNumber
    @NSManaged var jackpotAmount: String?
}
