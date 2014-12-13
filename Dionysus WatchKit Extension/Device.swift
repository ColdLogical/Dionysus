//
//  Device.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

public let kActionKey = "Action"
public let kAlias = "alias"
public let kAliasKey = "Alias"
public let kDeviceKey = "Device"
public let kIsDefault = "isDefault"
public let kIsDefaultKey = "DefaultDevice"
public let kDVR = "dvr"
public let kDVRKey = "DVR"
public let kMacAddress = "macAddress"
public let kMacAddressKey = "MacAddress"

@objc(Device)
public class Device: NSManagedObject {

    @NSManaged public var alias: String
    @NSManaged public var macAddress: String
    @NSManaged public var dvr: NSNumber
    @NSManaged public var isDefault: NSNumber
    
    public class func allDevices() -> [Device]! {
        if let results = DataManager.sharedInstance.fetchResults(kDeviceKey, predicate: nil) as? [Device] {
            return results
        }
        
        return [Device]()
    }
    
    public class func defaultDevice() -> Device? {
        if let results = DataManager.sharedInstance.fetchResults(kDeviceKey, predicate: NSPredicate(format: "isDefault == %@", true)) as? [Device] {
            if results.count > 0 {
                return results[0]
            }
        }
        
        return nil
    }
    
    public class func deleteDevice(device: Device!) {
        DataManager.sharedInstance.delete(device)
    }
    
    public class func existingOrNew(macAddress: String!) -> Device {
        let d = DataManager.sharedInstance.existingOrNewEntity(kDeviceKey, predicate: NSPredicate(format: "macAddress = %@", macAddress)) as Device
        
        if d.valueForKey(kMacAddressKey) as? String != macAddress {
            //A brand new entity, so set its macAddress
            d.macAddress = macAddress
            DataManager.sharedInstance.save()
        }
        
        return d
    }
    
    public class func existingOrNewFromDictionary(dictionary: NSDictionary!) -> Device {
        var d: Device?
        if let macAddress = dictionary[kMacAddressKey] as? String {
            d = Device.existingOrNew(macAddress)
        } else {
            d = Device.newDevice()
        }
        
        //Update values of entity
        d!.parseValues(dictionary)
        DataManager.sharedInstance.save()
        
        return d!
    }
    
    public class func newDevice() -> Device {
        return DataManager.sharedInstance.newEntity(kDeviceKey) as Device
    }
    
    public func parseValues(values: NSDictionary!) {
        self.setValue(values[kAliasKey] as? String ?? "", forKey:kAlias)
        self.setValue(values[kIsDefaultKey] as? String == "true" ? true : false, forKey:kIsDefault)
        self.setValue(values[kDVRKey] as? String == "true" ? true : false, forKey:kDVR)
        self.setValue(values[kMacAddressKey] as? String ?? "", forKey:kMacAddress)
        
        DataManager.sharedInstance.save()
    }
}
