//
//  MockOperations.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

class MockOperations : WebOperations {
    override class func login(completion: ((request: NSURLRequest, json: NSDictionary!) -> Void)?, failure: ((request: NSURLRequest, json: NSDictionary!) -> Void)?) {
        MockOperations.login("your mom", password: "really your mom", completion: completion, failure: failure)
    }
    
    override class func login(username: String, password: String, completion: ((request: NSURLRequest, json: NSDictionary!) -> Void)?, failure: ((request: NSURLRequest, json: NSDictionary!) -> Void)?) {
        println("mocking data")
        if let path = NSBundle.mainBundle().pathForResource("Login", ofType: "plist") {
            //A valid successful login response will have a AuthResponse dictionary
            if let data = NSDictionary(contentsOfFile: path) {
                println("mocked data: \(data)")
                if let authorized = data["AuthResponse"] as? NSDictionary {
                    if let token = authorized["Token"] as? String {
                        MockOperations.setAuthToken(token)
                        if completion != nil {
                            completion!(request: NSURLRequest(), json: authorized)
                        }
                    } else {
                        println("No Token in JSON data with request = \(data)")
                    }
                } else {
                    //If there is no Auth Response, then its probably an error 。・゜・(ノД`)・゜・。
                    MockOperations.setAuthToken(nil)
                    if let error = data["Error"]  as? NSArray {
                        if let errorDict = error[0] as? NSDictionary {
                            if failure != nil {
                                failure!(request: NSURLRequest(), json: errorDict)
                            }
                        }
                    }
                }
            }
        }
    }
}
