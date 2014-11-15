//
//  Channel.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

class Channel: NSManagedObject {

    @NSManaged var channelId: String
    @NSManaged var callSign: String
    @NSManaged var number: String

}
