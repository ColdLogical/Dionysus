//
//  Device+Extensions.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/19/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

let kAliasKey = "Alias"
let kIsDefaultKey = "DefaultDevice"
let kDVRKey = "DVR"
let kMacAddressKey = "MacAddress"

extension Device {
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
        self.alias = values[kAliasKey] as? String ?? ""
        self.isDefault = values[kIsDefaultKey] as? NSNumber ?? false
        self.dvr = values[kDVRKey] as? NSNumber ?? false
        self.macAddress = values[kMacAddressKey] as? String ?? ""
        
        DataManager.sharedInstance.save()
    }
}
