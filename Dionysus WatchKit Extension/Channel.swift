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
public let kImageKey = "Image"
public let kImageURIKey = "ImageUri"
public let kIsFavorite = "isFavorite"
public let kNetworkLogoURI = "networkLogoURI"
public let kNetworkLogoURIKey = "NetworkLogoUri"
public let kNumber = "number"
public let kNumberKey = "ChannelNumber"
public let kSeasonNumber = "seasonNumber"
public let kSeasonNumberKey = "Season"
public let kTitle = "title"
public let kTitleDescriptionKey = "LongDescription"
public let kTitleDescription = "titleDescription"
public let kTitleEndDate = "titleEndDate"
public let kTitleEndDateKey = "EndDate"
public let kTitleId = "titleId"
public let kTitleIdKey = "TitleId"
public let kTitleImage = "titleImageURI"
public let kTitleKey = "Title"
public let kTitleNameKey = "Name"
public let kTitleStartDate = "titleStartDate"
public let kTitleStartDateKey = "StartDate"

@objc(Channel)
/**
*       Managed object that represents a Channel with associated information, such as ESPN or Disney.
*/
public class Channel: NSManagedObject {
        
        /// The callsign of the channel
        @NSManaged public var callSign: String
        /// The unique channel identification number, in a string
        @NSManaged public var channelId: String
        /// The episode number of the currently playing asset on the channel
        @NSManaged public var episodeNumber: String
        /// The episode title of the currently playing asset on the channel
        @NSManaged public var episodeTitle: String
        /// A boolean indicating if the channel is a favorite channel
        @NSManaged public var isFavorite: NSNumber
        /// The network logo URI, used to dynamically download the image for the network logo
        @NSManaged public var networkLogoURI: String
         /// The channel number, in a string
        @NSManaged public var number: String
        /// The season number of the currently playing asset on the channel
        @NSManaged public var seasonNumber: String
        /// The title of the currently playing asset on the channel
        @NSManaged public var title: String
        /// The end date of the currently playing asset on the channel
        @NSManaged public var titleEndDate: NSDate
        /// The id of the currently playing asset on the channel
        @NSManaged public var titleId: String
        /// The start date of the currently playing asset on the channel
        @NSManaged public var titleStartDate: NSDate
        
        /**
        Fetches a list of all the channel objects marked as favorites from the managed object context.
        
        :returns: An array of all channels marked as favorites.
        */
        public class func allFavorites() -> [Channel] {
                if let results = DataManager.sharedInstance.fetchResults(kChannelKey, predicate: NSPredicate(format: "isFavorite = %@", true)) as? [Channel] {
                        return results
                }
                
                return [Channel]()
        }
        
        /**
        Function that creates the asset image URI that will be resized by the server.
        
        :param: width Integer of the width the image needs to be resized to
        
        :returns: The URI of the asset image with the width paramater attached, for resizing by the server
        */
        public func assetImageURIWithWidth(width: Int) -> String? {
                if var assetURI = valueForKey(kTitleImage) as? String {
                        let resizedURI: String = assetURI + "?w=\(width)"
                        return resizedURI
                }
                
                return nil
        }
        
        /**
        Helper function to delete a channel object.
        
        :param: channel The specific channenl to delete.
        */
        public class func deleteChannel(channel: Channel!) {
                DataManager.sharedInstance.delete(channel)
        }
        
        /**
        Function that will return a properly formatted string representing information about the season, episode, and title.
        
        :returns: A string in various formats such as "(S#, E#) Title"
        */
        public func episodeText() -> String {
                let seasonNumber = valueForKey(kSeasonNumber) as? String
                let episodeNumber = valueForKey(kEpisodeNumber) as? String
                let episodeTitle = valueForKey(kEpisodeTitle) as? String
                
                var text = String()
                
                if seasonNumber != nil && episodeNumber != nil && episodeTitle != nil {
                        text = "(S\(seasonNumber!), E\(episodeNumber!)) \(episodeTitle!)"
                }
                
                return text
        }
        
        /**
        Helper function to create a channel object based on channel ID.
        
        :param: channelId A string representation of the channel ID.
        
        :returns: A channel object with the input channel ID
        */
        public class func existingOrNew(channelId: String!) -> Channel {
                let c = DataManager.sharedInstance.existingOrNewEntity("Channel", predicate: NSPredicate(format: "channelId = %@", channelId)) as Channel
                
                if c.valueForKey(kChannelIdKey) as? String != channelId {
                        //A brand new entity, so set its macAddress
                        c.channelId = channelId
                        DataManager.sharedInstance.save()
                }
                
                return c
        }
        
        /**
        Helper function to create a channel object, still based on channel ID, but it will pull the channel ID from the dictionary that is passed in under the key "ChannelId".
        
        :param: dictionary A dictionary with associated channel ID data under the "ChannelId" key.
        
        :returns: A channel object with the input channel ID
        */
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
        
        /**
        Helper function that creates a brand new channel with defaults values.
        
        :returns: A new channel object.
        */
        public class func newChannel() -> Channel {
                return DataManager.sharedInstance.newEntity("Channel") as Channel
        }
        
        /**
        Function that creates the network logo image URI that will be resized by the server.
        
        :param: width Integer of the width the image needs to be resized to
        
        :returns: The URI of the network logo image with the width paramater attached, for resizing by the server
        */
        public func networkImageURIWithWidth(width: Int) -> String? {
                if var networkURI = valueForKey(kNetworkLogoURI) as? String {
                        let resizedURI: String = networkURI + "?w=\(width)"
                        return resizedURI
                }
        
                return nil
        }
        
        /**
        Helper function that sets the channel's associated values to the values from the dictionary. The dictionary is typically returned from the web services and parsed using this method.
        
        :param: values A dictionary with any combination of values.
        */
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
                                                
                                                if let endString = deliveryDict[kTitleEndDateKey] as? NSString {
                                                        let endDate = NSDate(timeIntervalSince1970: endString.doubleValue)
                                                        self.setValue(endDate, forKey: kTitleEndDate)
                                                }
                                        }
                                }
                                
                                self.setValue(dict[kEpisodeNumberKey] as? String, forKey:kEpisodeNumber)
                                self.setValue(dict[kEpisodeTitleKey] as? String, forKey:kEpisodeTitle)
                                self.setValue(dict[kTitleIdKey] as? String, forKey:kTitleId)
                                self.setValue(dict[kTitleNameKey] as? String, forKey:kTitle)
                                self.setValue(dict[kSeasonNumberKey] as? String, forKey:kSeasonNumber)
                        }
                }
                
                DataManager.sharedInstance.save()
        }
        
        /**
        Function that will return a properly formatted string representing information about the asset's current time frame.
        
        :returns: A string in various formats such as "7:00 - 8:00"
        */
        public func timeText() -> String {
                var text = String()
                
                if let startDate = valueForKey(kTitleStartDate) as? NSDate {
                        let formatter = NSDateFormatter()
                        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
                        
                        let startString = formatter.stringFromDate(startDate)
                        if let endDate = valueForKey(kTitleEndDate) as? NSDate {
                                let endString = formatter.stringFromDate(endDate)
                                text = "\(startString) - \(endString)"
                        } else {
                                text = "\(startString)"
                        }
                } else {
                        text = ""
                }
                
                return text
        }
}
