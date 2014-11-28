//
//  Channel.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

public let kChannelKey = "Channel"

@objc(Channel)
public class Channel: NSManagedObject {

    @NSManaged public var channelId: String
    @NSManaged public var callSign: String
    @NSManaged public var number: String

}
