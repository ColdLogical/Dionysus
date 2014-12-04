//
//  DeviceTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/19/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest
import CoreData
import Dionysus

class DeviceTests: XCTestCase {
    let dictionary = [kAliasKey: "YourMomsAlias",
        kMacAddressKey: "YourMom",
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
    
    func testDeleteDevice() {
        //Delete the test object
        Device.deleteDevice(testDevice)
        
        //Make sure it is gone
        var error: NSError?
        let fetchRequest = NSFetchRequest()
        let context = DataManager.sharedInstance.context
        
        let entity = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "macAddress == %@", dictionary[kMacAddressKey]! as String)
        
        let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error)
        
        XCTAssert(fetchedObjects!.count == 0, "No objects should be found with mac address after it was deleted")
    }
    
    func testExistingOrNew() {
        //Try to get an existing device
        let existingDevice = Device.existingOrNew(dictionary[kMacAddressKey]! as String)
        
        //Make sure it is the existing one
        XCTAssert(existingDevice.objectID == testDevice!.objectID, "Must return existing instance of device with unique identfier")
        let oldID = testDevice!.objectID
        
        //Delete it
        let context = DataManager.sharedInstance.context
        context.deleteObject(existingDevice)
        
        //Try to get a new one
        let newDevice = Device.existingOrNew(dictionary[kMacAddressKey]! as String)
        
        //Make sure its new
        XCTAssert(newDevice.objectID != oldID, "Must return a new instance if none exists")
        context.deleteObject(newDevice)
    }
    
    func testExistingOrNewFromDictionary() {
        //Try to get existing device
        let existingDevice = Device.existingOrNewFromDictionary(dictionary)
        
        //Make sure it is the existing one
        XCTAssert(existingDevice.objectID == testDevice!.objectID, "Must return existing instance of device with unique identfier")
        XCTAssert(existingDevice.valueForKey(kAlias) as? String == testDevice!.valueForKey(kAlias) as? String, "Alias must be equal")
        XCTAssert(existingDevice.valueForKey(kDVR) as? NSNumber == testDevice!.valueForKey(kDVR) as? NSNumber, "DVR must be equal")
        XCTAssert(existingDevice.valueForKey(kIsDefault) as? NSNumber == testDevice!.valueForKey(kIsDefault) as? NSNumber, "isDefault must be equal")
        XCTAssert(existingDevice.valueForKey(kMacAddress) as? String == testDevice!.valueForKey(kMacAddress) as? String, "MacAddress must be equal")
    }
    
    func testNewDevice() {
        //Add objects with the newEntity function
        let d: Device = Device.newDevice()
        
        //Check that they exist
        let context = DataManager.sharedInstance.context
        XCTAssert(d == context.objectWithID(d.objectID), "New object must exist in context")
        
        //Clean up by deleting temp objects
        context.deleteObject(d)
    }

    func testParseValues() {
        let context = DataManager.sharedInstance.context
        if let d = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: context) as? Device {
            d.parseValues(dictionary)
            
            XCTAssert(d.valueForKey(kAlias) as? String == dictionary[kAliasKey], "Parsed value must equal value inputted")
            XCTAssert(d.valueForKey(kDVR) as? NSNumber == dictionary[kDVRKey], "Parsed value must equal value inputted")
            XCTAssert(d.valueForKey(kIsDefault) as? NSNumber == dictionary[kIsDefaultKey], "Parsed value must equal value inputted")
            XCTAssert(d.valueForKey(kMacAddress) as? String == dictionary[kMacAddressKey], "Parsed value must equal value inputted")
            
            context.deleteObject(d)
        } else {
            assert(true, "Couldn't create Device object to test with")
        }
    }

}
