//
//  DataManagerTests.swift
//  Dionysus
//
//  Created by Cold Logic on 11/24/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import Dionysus

class DataManagerTests: XCTestCase {
    let dictionary = [kAliasKey: "Alias",
        kMacAddressKey: "macaddress",
        kDVRKey: true,
        kIsDefaultKey: false]
    var testDevice: Device?
    
    override func setUp() {
        super.setUp()
        
        let context = DataManager.sharedInstance.context
        
        testDevice = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: context) as? Device
        
        if testDevice != nil {
            testDevice!.parseValues(dictionary)
            DataManager.sharedInstance.save()
        } else {
            assert(testDevice != nil, "Test device cannot be nil at end of setup")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        if testDevice != nil {
            DataManager.sharedInstance.context.deleteObject(testDevice!)
            DataManager.sharedInstance.save()
        }
    }
    
    func testDelete() {
        //Delete the object
        DataManager.sharedInstance.delete(testDevice)
        
        //Make sure it is gone
        var error: NSError?
        let fetchRequest = NSFetchRequest()
        let context = DataManager.sharedInstance.context
        
        let entity = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "macAddress == %@", dictionary[kMacAddressKey] as String)
        
        let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error)
        
        XCTAssert(fetchedObjects!.count == 0, "No objects should be found with mac address after it was deleted")
    }
    
    func testExistingOrNewEntity() {
        //Make sure testDevice is returned from existingOrNew function
        
        //Setup a crazy mac address
        let macAddr = "OMFGImSuchACoolMacAddress"
        
        //Make sure it doesn't exist in the context yet
        var error: NSError?
        let fetchRequest = NSFetchRequest()
        let context = DataManager.sharedInstance.context
        let pred = NSPredicate(format: "macAddress == %@", macAddr)
        
        let entity = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.predicate = pred
        
        if let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error) {
            for fetchedDevice in fetchedObjects {
                context.deleteObject(fetchedDevice as NSManagedObject)
            }
        }
        
        //Create it using existingOrNew
        let d = DataManager.sharedInstance.existingOrNewEntity("Device", predicate: pred) as Device
        d.setValue(macAddr, forKey: kMacAddress)
        DataManager.sharedInstance.save()
        
        //Make sure its there
        let newFetched = context.executeFetchRequest(fetchRequest, error: &error)
        XCTAssert(newFetched!.count == 1, "ExistingOrNew must create a matching object")
        XCTAssert(newFetched![0].valueForKey(kMacAddress) as String == macAddr, "ExistingOrNew must create a matching object")
        
        //Clean it up
        context.deleteObject(newFetched![0] as NSManagedObject)
        
    }
    
    func testFetchResults() {
        //Fetch the device created in setup
        let results = DataManager.sharedInstance.fetchResults("Device", predicate: NSPredicate(format: "macAddress == %@", dictionary[kMacAddressKey] as String))
        
        //Make sure fetch returns an array
        XCTAssertNotNil(results, "Fetch should always return an array, even if it is empty")
        
        //There is only one result for this fetch
        XCTAssert(results!.count == 1, "Should only be one result for fetch result with identifier predicate")
        
        //Make sure the correct device was fetched
        XCTAssert(results![0].valueForKey(kMacAddress) as? String == dictionary[kMacAddressKey] as? String, "Mac Address of result should be equal to predicate input")
    }
    
    func testNewEntity() {
        //Add objects with the newEntity function
        let d: Device = DataManager.sharedInstance.newEntity("Device") as Device
        let c: Channel = DataManager.sharedInstance.newEntity("Channel") as Channel
        
        //Check that they exist
        let context = DataManager.sharedInstance.context
        XCTAssert(d == context.objectWithID(d.objectID), "New object must exist in context")
        XCTAssert(c == context.objectWithID(c.objectID), "New object must exist in context")
        
        //Clean up by deleting temp objects
        context.deleteObject(d)
        context.deleteObject(c)
    }
}

