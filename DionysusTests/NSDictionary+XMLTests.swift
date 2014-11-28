//
//  NSDictionary+XMLTests.swift
//  Dionysus
//
//  Created by Cold Logic on 11/28/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit
import XCTest
import Dionysus

class NSDictionary_XMLTests: XCTestCase {
    let dictionary: NSDictionary = ["I Dont Like": "Your Mom"]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXML() {
        //Make sure it has a header
        let xml = dictionary.XML()
        XCTAssertTrue(xml.hasPrefix(kXMLHeader), "XML has to be prefixed by the XML header")
        
        //Check that the end is the XML of values
        XCTAssertTrue(xml.hasSuffix(dictionary.XMLOfValues()), "XML must have XML of values of dictionary")
    }
    
    
    func testXMLOfValues() {
        //Check that the key and value get generated into XML
        XCTAssert(dictionary.XMLOfValues() == "<I Dont Like>Your Mom</I Dont Like>", "XMLilization should generate XML with key, value and closing key")
        
        //Check that it recurses if it finds a dictionary
        let rootDictionary: NSDictionary = ["Your Sister Though!": dictionary]
        XCTAssert(rootDictionary.XMLOfValues() == "<Your Sister Though!><I Dont Like>Your Mom</I Dont Like></Your Sister Though!>", "XMLilization should generate XML with key, value and closing key")
    }

}
