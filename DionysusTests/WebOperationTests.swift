//
//  WebOperationTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/7/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import XCTest

class WebOperationTests: XCTestCase {
    //Login Input just to test
    let input = "http://ctva.engprod-charter.net/api/symphony/auth/login"
    //Test account parameters
    let params = ["username": "coldlogic@charter.net", "password": "eXsC5s87r2vM"]
    
    func testURLInit() {
        let webOp: WebOperation = WebOperation(URL: input, parameters: params)
        
        XCTAssert(webOp.urlString == input, "URL String of WebOperation should be equal to input string")
        
        XCTAssertNotNil(webOp.request, "Request cannot be nil after init")
        XCTAssert(webOp.request!.URL!.absoluteString == input, "Request's URL must be equal to input string")
    }
}
