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
        
        let d = Device()
        d.parseValues(dictionary)
        
        XCTAssert(d.alias == testAlias, "Parsed value must equal value inputted")
        XCTAssert(d.dvr == testDVR, "Parsed value must equal value inputted")
        XCTAssert(d.isDefault == testIsDefault, "Parsed value must equal value inputted")
        XCTAssert(d.macAddress == testMacAddress, "Parsed value must equal value inputted")
    }

}
