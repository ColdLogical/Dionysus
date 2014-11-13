//
//  WebOperationsTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 2014. 11. 12..
//  Copyright (c) 2014년 Charter. All rights reserved.
//

import Foundation
import XCTest

class WebOperationsTests: XCTestCase {
    let userDefaults = NSUserDefaults()
    let configFileName = "TestConfig.plist"
    var configPath: String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDirectory: String! = paths[0]  as String
        return docDirectory.stringByAppendingPathComponent(configFileName)
    }
    let baseURL = "OmgCoolBaseURL"
    let password = "evenCoolerPassword"
    let username = "superCoolUsername"
    
    
    override func setUp() {
        //Setup a test config file
        let defaultConfig: NSDictionary = [kBaseURLKey: baseURL,
            kDefaultUsernameKey: username,
            kDefaultPasswordKey: password]
        defaultConfig.writeToFile(configPath, atomically: true)
        
        WebOperations.setConfiguration(configPath)
    }
    
    override func tearDown() {
        //Remove the test config file
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        fileManager.removeItemAtPath(configPath, error: &error)
        
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
    }
    
    func testAuthToken() {
        //Alter authToken in userDefaults
        let testToken = "TOKEN"
        userDefaults.setValue(testToken, forKey: kAuthTokenKey)
        
        //Make sure the token we set gets returned
        let token = WebOperations.AuthToken()
        XCTAssert(token == testToken, "Token must be value found in userDefaults")
    }
    
    func testBaseURL() {
        
    }
    
    func testConfiguration() {

    }
    
    func testDefaultConfigPath() {
        //Make sure the default path is for a plist file named DionysusConfig
        let defaultPath = WebOperations.defaultConfigPath()
        XCTAssert(defaultPath.lastPathComponent == "DionysusConfig.plist")
        
        //Check to see if file exists
        XCTAssert(NSFileManager.defaultManager().fileExistsAtPath(defaultPath), "Path must point to a file")
        
        //Config file must contain a dictionary
        let defaultDict = NSDictionary(contentsOfFile: defaultPath)
        XCTAssertNotNil(defaultDict, "File must be a representation of a dictionary")
    }
    
    func testLoginParameters() {
        let params = WebOperations.loginParameters()
        XCTAssertNotNil(params[kUsernameKey], "Username cannot be nil")
        XCTAssert(params[kUsernameKey]!.isEmpty == false, "Username cannot be empty")
        XCTAssertNotNil(params[kPasswordKey], "Password cannot be nil")
        XCTAssert(params[kPasswordKey]!.isEmpty == false, "password cannot be empty")
    }
    
    func testLoginURL() {
        XCTAssert(WebOperations.loginURL() == (WebOperations.baseURL() + kLoginEndpoint), "Login URL must be combination of baseURL and login endpoint")
    }
    
    //This doesn't test that the login function works correctly
    //  but rather that the information we get from login is what we need
    func testLogin() {
        var failExp = expectationWithDescription("Login Fail Test")
        func failure(request: NSURLRequest, json: NSDictionary!) -> Void {
            XCTAssertNotNil(json, "Should have recieved data")
            
            //Example Response
            //                {
            //                    Code = "Auth Login Failure";
            //                    Message =             (
            //                        "Failed to authenticate user: coldlogic@charter.net",
            //                        "Failed to authenticate user",
            //                        "Procedure results are unsuccessful :: The account is locked."
            //                    );
            //                    Timestamp = 1415838200044;
            //                    TransactionId = "ac1ebca8-1415838199509-43978";
            //                }
            
            XCTAssertNotNil(json["Code"], "Failed Login JSON must have a Code")
            
            failExp.fulfill()
        }
        
        var succExp = expectationWithDescription("Login Success Test")
        func success(request: NSURLRequest, json: NSDictionary!) -> Void {
            XCTAssertNotNil(json, "Should have recieved data")
            
            //Example Response
            //            {
            //                AccountNumber = 8352306990141788;
            //                Expiration = 1447267996233;
            //                ExpirationCookie = "Wed, 11 Nov 2015 18:53:16 UTC";
            //                Fullname = "coldlogic@charter.net";
            //                IssueDate = 0;
            //                Token = "58e2dfce-e79c-4435-9b6e-5a0a21144169";
            //                Username = "coldlogic@charter.net";
            //                ZipCode = 80219;
            //            }
            
            XCTAssertNotNil(json["Token"], "JSON has no Token")
            
            succExp.fulfill()
        }
        
        //Test with bad credentials
        WebOperations.login("yourmom", password: "reallyyourmom", completion: nil, failure:failure)
        
        //Test with default credentials provided by config file
        WebOperations.login(success, failure:nil)
        
        waitForExpectationsWithTimeout(10) { (error: NSError!) in
            XCTAssert(true, "Login timed out")
        }
    }
    
    func testSetAuthToken() {
        let testToken = "TOKEN"
        WebOperations.setAuthToken(testToken)
        
        let token = userDefaults.valueForKey(kAuthTokenKey) as String
        
        XCTAssertNotNil(token, "Value for kAuthTokenKey cannot be nil after setting it")
        XCTAssert(token == testToken, "Token must be value found in userDefaults")
    }
    
    func testSetUserDefault() {
        let value = "Your Mom"
        let key = "Your Mom Key"
        WebOperations.setUserDefault(value, key: key)
        
        XCTAssert(userDefaults.valueForKey(key) as? String == value, "Value in user defaults must equal value that was set")
    }
    
    func testUserDefaultValue() {
        let value = "Your Mom"
        let key = "Your Mom Key"
        userDefaults.setValue(value, forKey: key)
        
        XCTAssert(WebOperations.userDefaultForKey(key) == value, "Value must equal value in userDefaults")
    }
}
