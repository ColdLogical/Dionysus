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
/**
*       Managed Object that represents the associated data with a Device such as a sling box or a real set top box.
*/
public class Device: NSManagedObject {
        /// The alias of the device. Typically a description like "Living Room".
        @NSManaged public var alias: String
        /// An unique identifier for the device. Used for network calls to send information or commands such as tune to channel or record.
        @NSManaged public var macAddress: String
         /// Boolean of if the device has DVR capabilities.
        @NSManaged public var dvr: NSNumber
         /// Boolean of if the device is considered the default device for commands.
        @NSManaged public var isDefault: NSNumber
        
        /**
        Helper function that will gather all of the devices in the managed object context.
        
        :returns: A non-sorted array of all devices in the managed objcet context.
        */
        public class func allDevices() -> [Device]! {
                if let results = DataManager.sharedInstance.fetchResults(kDeviceKey, predicate: nil) as? [Device] {
                        return results
                }
                
                return [Device]()
        }
        
        /**
        Helper function that will find the device marked as default. Technicially, there should only ever be 1 default device, but if there are multiple, this function will return the first one it recevies from the fetch request.
        
        :returns: A single Device object that has been marked as the default.
        */
        public class func defaultDevice() -> Device? {
                if let results = DataManager.sharedInstance.fetchResults(kDeviceKey, predicate: NSPredicate(format: "isDefault == %@", true)) as? [Device] {
                        if results.count > 0 {
                                return results[0]
                        }
                }
                
                return nil
        }
        
        /**
        Deletes a specific device from the managed object context

        :param: device The specific device to delete
        */
        public class func deleteDevice(device: Device!) {
                DataManager.sharedInstance.delete(device)
        }
        
        /**
        Helper function to create a device object based on MAC address. If no device object exists with the MAC address, a new one will be created and assigned the MAC address, then saved to the managed object context.
        
        :param: macAddress The MAC address that uniquely identifies the device
        
        :returns: A device object with a matching  MAC address.
        */
        public class func existingOrNew(macAddress: String!) -> Device {
                let d = DataManager.sharedInstance.existingOrNewEntity(kDeviceKey, predicate: NSPredicate(format: "%K = %@", kMacAddress, macAddress)) as Device
                
                if d.valueForKey(kMacAddressKey) as? String != macAddress {
                        //A brand new entity, so set its macAddress
                        d.macAddress = macAddress
                        DataManager.sharedInstance.save()
                }
                
                return d
        }
        
        /**
        Helper function to create a device object, still based on MAC address, but it will pull the MAC address from the dictionary that is passed in under the key "MacAddress".
        
        :param: dictionary A dictionary with associated MAC address data under the "MacAddress" key.
        
        :returns: A device object with the input MAC address
        */
        public class func existingOrNewFromDictionary(dictionary: NSDictionary!) -> Device {
                var d: Device?
                if let macAddress = dictionary[kMacAddressKey] as? String {
                        d = Device.existingOrNew(macAddress)
                } else {
                        assert(true, "No value found for key \(kMacAddressKey). To use this function, the dictionary passed in must have a value for the MAC address of the device")
                }
                
                //Update values of entity
                d!.parseValues(dictionary)
                DataManager.sharedInstance.save()
                
                return d!
        }
        
        /**
        Helper function to create a new device in the managed object context.
        
        :returns: A brand spanking new device object with default values.
        */
        public class func newDevice() -> Device {
                return DataManager.sharedInstance.newEntity(kDeviceKey) as Device
        }
        
        /**
        Helper function that sets the devices associated values to the values from the dictionary.
        
        :param: values A dictionary with any combination of values for alias, MAC address, is default device, and has DVR capabilities.
        */
        public func parseValues(values: NSDictionary!) {
                self.setValue(values[kAliasKey] as? String ?? "", forKey:kAlias)
                self.setValue(values[kIsDefaultKey] as? String == "true" ? true : false, forKey:kIsDefault)
                self.setValue(values[kDVRKey] as? String == "true" ? true : false, forKey:kDVR)
                self.setValue(values[kMacAddressKey] as? String ?? "", forKey:kMacAddress)
                
                DataManager.sharedInstance.save()
        }
}
