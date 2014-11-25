//
//  WebOperationTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/7/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest
import Dionysus

class WebOperationTests: XCTestCase {
    //Login Input just to test
    let input = "http://ctva.engprod-charter.net/api/symphony/auth/login"
    //Test account parameters
    let params = ["username": "coldlogic@charter.net", "password": "eXsC5s87r2vM"]
    
    func testURLInit() {
        let webOp = WebOperation(URL: input)
        
        XCTAssert(webOp.urlString == input, "URL String of WebOperation should be equal to input string")
        
        XCTAssertNotNil(webOp.request, "Request cannot be nil after init")
        XCTAssert(webOp.request!.URL!.absoluteString == input, "Request's URL must be equal to input string")
    }
    
    func testParameterInit() {
        let webOp = WebOperation(URL: input, parameters: params)
        
        //Make sure the urlString is set
        XCTAssertNotNil(webOp.urlString, "URL string cannot be nil")
        
        //Check to see if its set correctly
        if var dataString = webOp.urlString {
            //Remove the url
            dataString = dataString.stringByReplacingOccurrencesOfString("\(input)", withString: "")
            
            //Remove each key and value
            for (key, value) in params {
                dataString = dataString.stringByReplacingOccurrencesOfString("\(key)=\(value)", withString: "")
            }
            
            //Remove ?
            dataString = dataString.stringByReplacingOccurrencesOfString("?", withString: "")
            
            //All that should be left are &s
            var ampersands = String()
            for i in 0 ..< params.keys.array.count - 1 {
                ampersands += "&"
            }
            
            XCTAssert(dataString == ampersands, "Data string must be combination of values and keys from dictionary with \"&\" delimeters")
        }
    }
    
    func testDataInit() {
        let webOp = WebOperation(URL: input, data: params)
        
        //Make sure the HTTPBody is set
        let data = webOp.request.HTTPBody
        XCTAssertNotNil(data, "HTTPBody cannot be nil")
        
        //Check to see if its set correctly
        if var dataString = NSString(data: data!, encoding: NSASCIIStringEncoding) {
            //Remove each key and value
            for (key, value) in params {
                dataString = dataString.stringByReplacingOccurrencesOfString("\(key)=\(value)", withString: "")
            }
            
            //All that should be left are &s
            var ampersands = String()
            for i in 0 ..< params.keys.array.count - 1 {
                ampersands += "&"
            }
            
            XCTAssert(dataString == ampersands, "Data string must be combination of values and keys from dictionary with \"&\" delimeters")
        } else {
            XCTAssert(true, "Data must be an encoded string")
        }
    }
    
    func testQueryString() {
        //Try with 2+ values
        let dictionary = [ "test1": "coolStuff",
            "test2": "evenCoolerStuff",
            "test3": "kindaCoolStuff"]
        
        var query = WebOperation.queryString(dictionary)
        
        //Remove each piece because their order isn't guarenteed in any way
        for (key, value) in dictionary {
            query = query.stringByReplacingOccurrencesOfString("\(key)=\(value)", withString: "")
        }
        
        //query should be only &s right here
        var ampersands = String()
        for i in 0 ..< dictionary.keys.array.count - 1 {
            ampersands += "&"
        }
        
        XCTAssert(query == ampersands, "Query string must be combination of values and keys from dictionary with & delimeters")
        
        //Try with single value
        let singleValue = [ "single": "test"]
        
        XCTAssert(WebOperation.queryString(singleValue) == "single=test", "Query string shouldn't have leading or ending delimeters")
    }
}
