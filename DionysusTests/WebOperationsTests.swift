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
    let workingPassword = "eXsC5s87r2vM"
    let workingUsername = "coldlogic@charter.net"
    
    
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
        let token = WebOperations.authToken()
        XCTAssert(token == testToken, "Token must be value found in userDefaults")
    }
    
    func testBaseURL() {
        XCTAssert(WebOperations.baseURL() == baseURL, "BaseURL return must equal that of the config file")
    }
    
    func testConfiguration() {
        let config = WebOperations.configuration()
        XCTAssertNotNil(config, "Configuration must return a dictionary")
        XCTAssert(config[kBaseURLKey] as? String == baseURL, "Configuration baseURL must be equal to the config files baseURL")
        XCTAssert(config[kDefaultUsernameKey] as? String == username, "Configuration username must be equal to the config files username")
        XCTAssert(config[kDefaultPasswordKey] as? String == password, "Configuration password must be equal to the config files password")
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
    
    func testLogin() {
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        let config = WebOperations.configuration()
        
        var failExp = expectationWithDescription("Login Fail Test")
        func failure(request: NSURLRequest, json: NSDictionary!) -> Void {
            XCTAssertNotNil(json, "Should have recieved data")
            
            //Example Response
            //            {
            //                Code = "Auth Login Failure";
            //                Message =             (
            //                    "Failed to authenticate user: yourmom",
            //                    "Failed to authenticate user",
            //                    "Procedure results are unsuccessful :: The name was not found in the system."
            //                );
            //                Timestamp = 1415991011447;
            //                TransactionId = "ac1ebcbf-1415991010753-85";
            //            }
            
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
            XCTAssert(json["Fullname"] as? String == config[kDefaultUsernameKey] as? String, "This Login test must login with credentials from the configuration file")
            
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
    
    func testSetBaseURL() {
        let value = baseURL
        WebOperations.setBaseURL(value)
        
        XCTAssert(userDefaults.valueForKey(kBaseURLKey) as? String == value, "Value in user defaults must equal value that was set")
    }
    
    func testSetConfiguration() {
        let value = configPath
        WebOperations.setConfiguration(value)
        
        XCTAssert(userDefaults.valueForKey(kConfigPathKey) as? String == value, "Value in user defaults must equal value that was set")
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
