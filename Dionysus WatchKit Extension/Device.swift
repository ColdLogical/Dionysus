//
//  Device.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

public let kAlias = "alias"
public let kAliasKey = "Alias"
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
    
    public class func deleteDevice(device: Device!) {
        DataManager.sharedInstance.delete(device)
    }
    
    public class func existingOrNew(macAddress: String!) -> Device {
        let d = DataManager.sharedInstance.existingOrNewEntity("Device", predicate: NSPredicate(format: "macAddress = %@", macAddress)) as Device
        
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
        return DataManager.sharedInstance.newEntity("Device") as Device
    }
    
    public func parseValues(values: NSDictionary!) {
        self.setValue(values[kAliasKey] as? String ?? "", forKey:kAlias)
        self.setValue(values[kIsDefaultKey] as? NSNumber ?? false, forKey:kIsDefault)
        self.setValue(values[kDVRKey] as? NSNumber ?? false, forKey:kDVR)
        self.setValue(values[kMacAddressKey] as? String ?? "", forKey:kMacAddress)
        
        DataManager.sharedInstance.save()
    }
}
