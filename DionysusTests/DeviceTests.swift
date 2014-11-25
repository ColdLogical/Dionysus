//
//  DeviceTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/19/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest
import Dionysus

class DeviceTests: XCTestCase {
    let dictionary = [kAliasKey: "YourMomsAlias",
        kMacAddressKey: "YourMom",
        kDVRKey: true,
        kIsDefaultKey: false]
    var testDevice: Device?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseValues() {
        let d = Device.newDevice()
        d.parseValues(dictionary)
        
        XCTAssert(d.valueForKey(kAlias) as? String == dictionary[kAliasKey], "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey(kDVR) as? NSNumber == dictionary[kDVRKey], "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey(kIsDefault) as? NSNumber == dictionary[kIsDefaultKey], "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey(kMacAddress) as? String == dictionary[kMacAddressKey], "Parsed value must equal value inputted")
		
		Device.deleteDevice(d)
    }

}
