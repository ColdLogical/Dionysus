//
//  ChannelTests.swift
//  Dionysus
//
//  Created by Cold Logic on 11/24/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest
import CoreData
import Dionysus

class ChannelTests: XCTestCase {
        let dictionary: NSDictionary = [ kChannelKey: [kChannelIdKey: "YourMomsID",
                kCallSignKey: "YourMom",
                kNumberKey: "25",
                kNetworkLogoURIKey: [[ kImageURIKey: "your mom is an image" ]]
                ],
                kTitleKey: [
                        [ kDeliveryKey: [ [kTitleStartDateKey: "0", kTitleEndDateKey: "3600"] ],
                                kSeasonNumberKey : "17",
                                kEpisodeNumberKey  : "3",
                                kTitleIdKey : "SisterBeHotID",
                                kTitleNameKey : "Your sister",
                                kEpisodeTitleKey : "Is Hot",
                        ]
        ] ]
        var testChannel: Channel?
        
        override func setUp() {
                super.setUp()
                
                let context = DataManager.sharedInstance.context
                
                testChannel = NSEntityDescription.insertNewObjectForEntityForName("Channel", inManagedObjectContext: context) as? Channel
                
                if testChannel != nil {
                        testChannel!.parseValues(dictionary)
                        testChannel!.setValue("picture of your sister", forKey:kTitleImage)
                        testChannel!.setValue("your sister, like OMG", forKey:kTitleDescription)
                        DataManager.sharedInstance.save()
                } else {
                        assert(testChannel != nil, "Test channel cannot be nil at end of setup")
                }
        }
        
        override func tearDown() {
                super.tearDown()
                
                if testChannel != nil {
                        DataManager.sharedInstance.context.deleteObject(testChannel!)
                        DataManager.sharedInstance.save()
                }
        }
        
        func testAllFavorites() {
                //Set the testChannel to be a favorite
                testChannel!.setValue(true, forKey: kIsFavorite)
                DataManager.sharedInstance.save()
                
                //Get all the favorites
                let favorites = Channel.allFavorites()
                
                //Check that there is only one and make sure its the correct one
                XCTAssert(favorites.count == 1, "All favorites is returning more than the favorites")
                XCTAssert(favorites[0].objectID == testChannel!.objectID, "The favorited channel must be returned in the array of favorites")
        }
        
        func testAssetImageURIWithWidth() {
                let uri = testChannel!.assetImageURIWithWidth(1000)
                
                XCTAssert(uri == "\(testChannel!.valueForKey(kTitleImage) as String)?w=1000", "Asset image uri must be a combination of the image uri and the input width")
        }
        
        func testDeleteChannel() {
                //Delete the test object
                Channel.deleteChannel(testChannel)
                
                //Make sure it is gone
                var error: NSError?
                let fetchRequest = NSFetchRequest()
                let context = DataManager.sharedInstance.context
                
                let entity = NSEntityDescription.entityForName("Channel", inManagedObjectContext: context)
                fetchRequest.entity = entity
                let channelDict = dictionary[kChannelKey] as NSDictionary
                fetchRequest.predicate = NSPredicate(format: "channelId == %@", channelDict[kChannelIdKey] as String)
                
                let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error)
                
                XCTAssert(fetchedObjects!.count == 0, "No objects should be found with channel id after it was deleted")
        }
        
        func testEpisodeText() {
                let text = testChannel!.episodeText()
                
                XCTAssert(text == "(S17, E3) Is Hot", "Episode text should return format \"(S#, E#) Title\"")
        }
        
        func testExistingOrNew() {
                //Try to get an existing channel
                let channelDict = dictionary[kChannelKey] as NSDictionary
                let existingChannel = Channel.existingOrNew(channelDict[kChannelIdKey] as String)
                
                //Make sure it is the existing one
                XCTAssert(existingChannel.objectID == testChannel!.objectID, "Must return existing instance of channel with unique identfier")
                let oldID = testChannel!.objectID
                
                //Delete it
                let context = DataManager.sharedInstance.context
                context.deleteObject(existingChannel)
                
                //Try to get a new one
                let newChannel = Channel.existingOrNew(channelDict[kChannelIdKey] as String)
                
                //Make sure its new
                XCTAssert(newChannel.objectID != oldID, "Must return a new instance if none exists")
                context.deleteObject(newChannel)
        }
        
        func testExistingOrNewFromDictionary() {
                //Try to get existing channel
                let existingChannel = Channel.existingOrNewFromDictionary(dictionary)
                
                //Make sure it is the existing one
                XCTAssert(existingChannel.objectID == testChannel!.objectID, "Must return existing instance of device with unique identfier")
                XCTAssert(existingChannel.valueForKey(kChannelId) as? String == testChannel!.valueForKey(kChannelId) as? String, "ChannelID must be equal")
                XCTAssert(existingChannel.valueForKey(kCallSign) as? String == testChannel!.valueForKey(kCallSign) as? String, "CallSign must be equal")
                XCTAssert(existingChannel.valueForKey(kNumber) as? String == testChannel!.valueForKey(kNumber) as? String, "Number must be equal")
        }
        
        func testNewChannel() {
                //Add objects with the newEntity function
                let c: Channel = Channel.newChannel()
                
                //Check that they exist
                let context = DataManager.sharedInstance.context
                XCTAssert(c == context.objectWithID(c.objectID), "New object must exist in context")
                
                //Clean up by deleting temp objects
                context.deleteObject(c)
        }
        
        func testNetworkImageURIWithWidth() {
                let uri = testChannel!.networkImageURIWithWidth(1000)
                
                XCTAssert(uri == "\(testChannel!.valueForKey(kNetworkLogoURI) as String)?w=1000", "Network image uri must be a combination of the network logo uri and the input width")
        }
        
        func testParseValues() {
                let context = DataManager.sharedInstance.context
                if let c = NSEntityDescription.insertNewObjectForEntityForName("Channel", inManagedObjectContext: context) as? Channel {
                        c.parseValues(dictionary)
                        
                        let channelDict = dictionary[kChannelKey] as NSDictionary
                        
                        XCTAssert(c.valueForKey(kChannelId) as? String == channelDict[kChannelIdKey] as? String, "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kCallSign) as? String == channelDict[kCallSignKey] as? String, "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kNumber) as? String == channelDict[kNumberKey] as? String, "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kNetworkLogoURI) as? String == ((channelDict[kNetworkLogoURIKey] as NSArray)[0] as NSDictionary)[kImageURIKey] as? String, "Parsed value must equal value inputted")
                        
                        //Please dont ever look at these lines
                        let titleDict = (dictionary[kTitleKey] as NSArray)[0] as NSDictionary
                        let deliveryDict = (titleDict[kDeliveryKey] as NSArray)[0] as NSDictionary
                        
                        let start = NSDate(timeIntervalSince1970: (deliveryDict[kTitleStartDateKey] as NSString).doubleValue)
                        XCTAssert(c.valueForKey(kTitleStartDate) as? NSDate == start, "Parsed value must equal value inputted")
                        
                        let end = NSDate(timeIntervalSince1970: (deliveryDict[kTitleEndDateKey] as NSString).doubleValue)
                        XCTAssert(c.valueForKey(kTitleEndDate) as? NSDate == end, "Parsed value must equal value inputted")
                        
                        XCTAssert(c.valueForKey(kEpisodeNumber) as? String == titleDict[kEpisodeNumberKey] as? String , "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kEpisodeTitle) as? String == titleDict[kEpisodeTitleKey] as? String , "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kTitle) as? String == titleDict[kTitleNameKey] as? String , "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kTitleId) as? String == titleDict[kTitleIdKey] as? String , "Parsed value must equal value inputted")
                        XCTAssert(c.valueForKey(kSeasonNumber) as? String == titleDict[kSeasonNumberKey] as? String , "Parsed value must equal value inputted")
                        
                        context.deleteObject(c)
                } else {
                        assert(false, "Couldn't create Channel object to test with")
                }
        }
        
        func testTimeText() {
                let text = testChannel!.timeText()
                
                XCTAssert(text == "5:00 PM - 6:00 PM", "Time text should return \"StartTime - EndTime\"")
        }
}
