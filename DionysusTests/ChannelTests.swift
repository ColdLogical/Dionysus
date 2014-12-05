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
    let dictionary = [kChannelIdKey: "YourMomsID",
        kCallSignKey: "YourMom",
        kNumberKey: "25"]
    var testChannel: Channel?
    
    override func setUp() {
        super.setUp()
        
        let context = DataManager.sharedInstance.context
        
        testChannel = NSEntityDescription.insertNewObjectForEntityForName("Channel", inManagedObjectContext: context) as? Channel
        
        if testChannel != nil {
            testChannel!.parseValues(dictionary)
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
    
    func testDeleteChannel() {
        //Delete the test object
        Channel.deleteChannel(testChannel)
        
        //Make sure it is gone
        var error: NSError?
        let fetchRequest = NSFetchRequest()
        let context = DataManager.sharedInstance.context
        
        let entity = NSEntityDescription.entityForName("Channel", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "channelId == %@", dictionary[kChannelIdKey]! as String)
        
        let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error)
        
        XCTAssert(fetchedObjects!.count == 0, "No objects should be found with channel id after it was deleted")
    }
    
    func testExistingOrNew() {
        //Try to get an existing channel
        let existingChannel = Channel.existingOrNew(dictionary[kChannelIdKey]! as String)
        
        //Make sure it is the existing one
        XCTAssert(existingChannel.objectID == testChannel!.objectID, "Must return existing instance of channel with unique identfier")
        let oldID = testChannel!.objectID
        
        //Delete it
        let context = DataManager.sharedInstance.context
        context.deleteObject(existingChannel)
        
        //Try to get a new one
        let newChannel = Channel.existingOrNew(dictionary[kChannelIdKey]! as String)
        
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
    
    func testParseValues() {
        let context = DataManager.sharedInstance.context
        if let c = NSEntityDescription.insertNewObjectForEntityForName("Channel", inManagedObjectContext: context) as? Channel {
            c.parseValues(dictionary)
            
            XCTAssert(c.valueForKey(kChannelId) as? String == dictionary[kChannelIdKey], "Parsed value must equal value inputted")
            XCTAssert(c.valueForKey(kCallSign) as? String == dictionary[kCallSignKey], "Parsed value must equal value inputted")
            XCTAssert(c.valueForKey(kNumber) as? String == dictionary[kNumberKey], "Parsed value must equal value inputted")
            
            context.deleteObject(c)
        } else {
            assert(true, "Couldn't create Channel object to test with")
        }
    }

}
