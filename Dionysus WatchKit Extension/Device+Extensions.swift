//
//  Device+Extensions.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/19/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

let kAlias = "alias"
let kAliasKey = "Alias"
let kIsDefault = "isDefault"
let kIsDefaultKey = "DefaultDevice"
let kDVR = "dvr"
let kDVRKey = "DVR"
let kMacAddress = "macAddress"
let kMacAddressKey = "MacAddress"

extension Device {
    class func deleteDevice(device: Device!) {
        DataManager.sharedInstance.delete(device)
    }
    
    class func existingOrNew(macAddress: String!) -> Device {
        let d = DataManager.sharedInstance.existingOrNewEntity("Device", predicate: NSPredicate(format: "macAddress = %@", macAddress)) as Device
        
        if d.valueForKey(kMacAddressKey) as? String != macAddress {
            //A brand new entity, so set its macAddress
            d.macAddress = macAddress
            DataManager.sharedInstance.save()
        }
        
        return d
    }
    
    class func existingOrNewFromDictionary(dictionary: NSDictionary!) -> Device {
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
    
    class func newDevice() -> Device {
        return DataManager.sharedInstance.newEntity("Device") as Device
    }
    
    func parseValues(values: NSDictionary!) {
        self.setValue(values[kAliasKey] as? String ?? "", forKey:kAlias)
        self.setValue(values[kIsDefaultKey] as? NSNumber ?? false, forKey:kIsDefault)
        self.setValue(values[kDVRKey] as? NSNumber ?? false, forKey:kDVR)
        self.setValue(values[kMacAddressKey] as? String ?? "", forKey:kMacAddress)
        
        DataManager.sharedInstance.save()
    }
}
