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
    let input = "http://www.coolwebsitebrah.com"
    //Test account parameters
    let params = ["username": "omgCoolUsername", "password": "yourmom"]
    
    func testAppendStringToData() {
        let webOp = WebOperation(URL: input)
        let testString = "Your Mom"
        
        //Check to see if body is empty
        XCTAssert(webOp.request.HTTPBody == nil, "HTTP Body must be nil after init")
        
        //Append a string
        webOp.appendStringToData(testString)
        
        //Check to see that the correct string was appended
        XCTAssert(webOp.request.HTTPBody?.isEqualToData(testString.dataUsingEncoding(NSASCIIStringEncoding)!) == true, "Data should be an encoded string equal to the test string")
        
        //Appeand an additional string
        let anotherString = "has questionable heterosexual tendencies"
        webOp.appendStringToData(anotherString)
        
        //Make sure that the data was appended correctly
        let testAppended = anotherString + testString
        XCTAssert(webOp.request.HTTPBody?.isEqualToData(testAppended.dataUsingEncoding(NSASCIIStringEncoding)!) == true, "Data should be a concatenated encoded string equal to the test strings")
    }
    
    func testDataInit() {
        let webOp = WebOperation(URL: input, data: params)
        
        //Make sure the HTTPBody is set
        let data = webOp.request.HTTPBody
        XCTAssertNotNil(data, "HTTPBody cannot be nil")
        
        //Should be a POST request
        XCTAssert(webOp.request.HTTPMethod == "POST", "Request must be a post request")
        
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
        } else {
            XCTAssert(true, "URL cannot be nil")
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
    
    func testURLInit() {
        let webOp = WebOperation(URL: input)
        
        XCTAssert(webOp.urlString == input, "URL String of WebOperation should be equal to input string")
        
        XCTAssertNotNil(webOp.request, "Request cannot be nil after init")
        XCTAssert(webOp.request!.URL!.absoluteString == input, "Request's URL must be equal to input string")
    }
    
    func testXMLInit() {
        let xml: NSDictionary = ["firstKey": "yourmom",
            "secondKey": "your other mom"]
        let webOp = WebOperation(URL: input, parameters: params, xmlDictionary: xml)
        
        //Make sure the HTTPBody is set
        let data = webOp.request.HTTPBody
        XCTAssertNotNil(data, "HTTPBody cannot be nil")
        
        //Should be a POST request
        XCTAssert(webOp.request.HTTPMethod == "POST", "Request must be a post request")
        
        //Check to see if its set correctly
        if var dataString = NSString(data: data!, encoding: NSASCIIStringEncoding) {
            XCTAssert(dataString == xml.XML(), "Data string must be an xml representation of the xml dictionary")
        } else {
            XCTAssert(true, "Data must be an encoded string")
        }
    }
}
