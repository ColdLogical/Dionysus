//
//  DeviceTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/19/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest

class DeviceTests: XCTestCase {
    let testAlias = "TestAlias"
    let testDVR = false
    let testIsDefault = true
    let testMacAddress = "YourMom"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseValues() {
        let dictionary = [kAliasKey: testAlias,
            kDVRKey: testDVR,
            kIsDefaultKey: testIsDefault,
            kMacAddressKey: testMacAddress]
        
        let d = Device.newDevice()
        d.parseValues(dictionary)
        
        XCTAssert(d.valueForKey("alias") as? String == testAlias, "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey("dvr") as? NSNumber == testDVR, "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey("isDefault") as? NSNumber == testIsDefault, "Parsed value must equal value inputted")
        XCTAssert(d.valueForKey("macAddress") as? String == testMacAddress, "Parsed value must equal value inputted")
		
		Device.deleteDevice(d)
    }

}
