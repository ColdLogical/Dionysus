//
//  Device.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

@objc(Device)
class Device: NSManagedObject {

    @NSManaged var alias: String
    @NSManaged var macAddress: String
    @NSManaged var dvr: NSNumber
    @NSManaged var isDefault: NSNumber

}
