//
//  MockOperations.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

/**
*       This class mocks WebOperations by determining if a certain end point is in the url, it then returns the data from the example plists.
*/
class MockOperations : WebOperation {
        override func connect(completion: ((request: NSURLRequest, json: NSDictionary) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                var data: NSDictionary?
                
                let str: NSString = urlString!
                
                if str.rangeOfString(kLoginEndpoint).location != NSNotFound {
                        println("Mocking Login")
                        if let loginData = WebOperations.dictionaryFromPlistNamed("Login") {
                                data = loginData
                        }
                }
                
                if str.rangeOfString(kDevicesEndpoint).location != NSNotFound {
                        if request.HTTPMethod == "GET" {
                                println("Mocking Device List")
                                if let deviceData = WebOperations.dictionaryFromPlistNamed("DeviceList") {
                                        data = deviceData
                                }
                        } else {
                                println("Mocking Tune To Channel on Device")
                                if let deviceData = WebOperations.dictionaryFromPlistNamed("TuneToChannel") {
                                        data = deviceData
                                }
                        }
                }
                
                if str.rangeOfString(kFavoritesEndpoint).location != NSNotFound {
                        println("Mocking Favorites")
                        if let deviceData = WebOperations.dictionaryFromPlistNamed("Favorites") {
                                data = deviceData
                        }
                }
                
                if completion != nil {
                        if data != nil {
                                completion!(request: NSURLRequest(), json: data! as NSDictionary)
                        } else {
                                completion!(request: NSURLRequest(), json: NSDictionary())
                        }
                }
        }
}
