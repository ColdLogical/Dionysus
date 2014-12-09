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
public let kCallSignKey = "NetworkCode"
public let kChannelId = "channelId"
public let kChannelKey = "Channel"
public let kChannelIdKey = "ChannelId"
public let kDeliveryKey = "Delivery"
public let kEpisodeNumber = "episodeNumber"
public let kEpisodeNumberKey = "Episode"
public let kEpisodeTitle = "episodeTitle"
public let kEpisodeTitleKey = "EpisodeName"
public let kImageURIKey = "ImageUri"
public let kIsFavorite = "isFavorite"
public let kNetworkLogoURI = "networkLogoURI"
public let kNetworkLogoURIKey = "NetworkLogoUri"
public let kNumber = "number"
public let kNumberKey = "ChannelNumber"
public let kSeasonNumber = "seasonNumber"
public let kSeasonNumberKey = "Season"
public let kTitle = "title"
public let kTitleKey = "Title"
public let kTitleNameKey = "Name"
public let kTitleEndDate = "titleEndDate"
public let kTitleEndDateKey = "EndDate"
public let kTitleStartDate = "titleStartDate"
public let kTitleStartDateKey = "StartDate"

@objc(Channel)
public class Channel: NSManagedObject {
    
    @NSManaged public var callSign: String
    @NSManaged public var channelId: String
    @NSManaged public var episodeNumber: String
    @NSManaged public var episodeTitle: String
    @NSManaged public var isFavorite: NSNumber
    @NSManaged public var networkLogoURI: String
    @NSManaged public var number: String
    @NSManaged public var seasonNumber: String
    @NSManaged public var title: String
    @NSManaged public var titleEndDate: NSDate
    @NSManaged public var titleStartDate: NSDate
    
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
        if let channelDict = dictionary[kChannelKey] as? NSDictionary {
            if let channelId = channelDict[kChannelIdKey] as? String {
                c = Channel.existingOrNew(channelId)
            } else {
                c = Channel.newChannel()
            }
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
        if let channelDict = values[kChannelKey] as? NSDictionary {
            self.setValue(channelDict[kChannelIdKey] as? String ?? "", forKey:kChannelId)
            self.setValue(channelDict[kCallSignKey] as? String ?? "", forKey:kCallSign)
            self.setValue(channelDict[kNumberKey] as? String ?? "", forKey:kNumber)
        
            if let networkArray = channelDict[kNetworkLogoURIKey] as? NSArray {
                for dict in networkArray {
                    self.setValue(dict[kImageURIKey] as? String ?? "", forKey:kNetworkLogoURI)
                }
            }
    }
    
        if let titleArray = values[kTitleKey] as? NSArray {
            if let dict = titleArray[0] as? NSDictionary {
                if let deliveryArray = dict[kDeliveryKey] as? NSArray {
                    if let deliveryDict = deliveryArray[0] as? NSDictionary {
                        if let startString = deliveryDict[kTitleStartDateKey] as? NSString {
                            let startDate = NSDate(timeIntervalSince1970: startString.doubleValue)
                            self.setValue(startDate, forKey: kTitleStartDate)
                        }
                        
                        if let endString = deliveryDict[kTitleStartDateKey] as? NSString {
                            let endDate = NSDate(timeIntervalSince1970: endString.doubleValue)
                            self.setValue(endDate, forKey: kTitleEndDate)
                        }
                    }
                }
                
                self.setValue(dict[kEpisodeNumberKey]  as? String, forKey:kEpisodeNumber)
                self.setValue(dict[kEpisodeTitleKey]  as? String, forKey:kEpisodeTitle)
                self.setValue(dict[kTitleNameKey]  as? String, forKey:kTitle)
                self.setValue(dict[kSeasonNumberKey]  as? String, forKey:kSeasonNumber)
            }
        }
        
        DataManager.sharedInstance.save()
    }

}
