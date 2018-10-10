//
//  PrizeValue.swift
//  LottoMagic
//
//  Created by Kirkland Poole on 3/28/16.
//  Copyright © 2016 Kirkland Poole. All rights reserved.
//

import UIKit
import CoreData

class PrizeValue: NSManagedObject {
    @NSManaged var gameId: NSNumber
    @NSManaged var prizeValueId: NSNumber
    @NSManaged var standardBallsMatched: NSNumber
    @NSManaged var bonusBallsMatched: NSNumber
    @NSManaged var prizeLevelValue: NSNumber
}
