//
//  Channel.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

public let kCallSign = "callSign"
public let kCallSignKey = "CallSignDisplayLabel"
public let kChannelId = "channelId"
public let kChannelKey = "Channel"
public let kChannelIdKey = "ChannelId"
public let kIsFavorite = "isFavorite"
public let kNumber = "number"
public let kNumberKey = "ChannelNumber"

@objc(Channel)
public class Channel: NSManagedObject {

    @NSManaged public var channelId: String
    @NSManaged public var callSign: String
    @NSManaged public var isFavorite: NSNumber
    @NSManaged public var number: String
    
    public class func allFavorites() -> [Channel] {
        if let results = DataManager.sharedInstance.fetchResults(kChannelKey, predicate: NSPredicate(format: "isFavorite = %@", true)) as? [Channel] {
            return results
        }
        
        return [Channel]()
    }
    
    public class func deleteChannel(channel: Channel!) {
        DataManager.sharedInstance.delete(channel)
    }
    
    public class func existingOrNew(channelId: String!) -> Channel {
        let c = DataManager.sharedInstance.existingOrNewEntity("Channel", predicate: NSPredicate(format: "channelId = %@", channelId)) as Channel
        
        if c.valueForKey(kChannelIdKey) as? String != channelId {
            //A brand new entity, so set its macAddress
            c.channelId = channelId
            DataManager.sharedInstance.save()
        }
        
        return c
    }
    
    public class func existingOrNewFromDictionary(dictionary: NSDictionary!) -> Channel {
        var c: Channel?
        if let channelId = dictionary[kChannelIdKey] as? String {
            c = Channel.existingOrNew(channelId)
        } else {
            c = Channel.newChannel()
        }
        
        //Update values of entity
        c!.parseValues(dictionary)
        DataManager.sharedInstance.save()
        
        return c!
    }
    
    public class func newChannel() -> Channel {
        return DataManager.sharedInstance.newEntity("Channel") as Channel
    }
    
    public func parseValues(values: NSDictionary!) {
        self.setValue(values[kChannelIdKey] as? String ?? "", forKey:kChannelId)
        self.setValue(values[kCallSignKey] as? String ?? "", forKey:kCallSign)
        self.setValue(values[kNumberKey] as? String ?? "", forKey:kNumber)
        
        DataManager.sharedInstance.save()
    }

}
