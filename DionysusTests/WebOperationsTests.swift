//
//  WebOperationsTests.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 2014. 11. 12..
//  Copyright (c) 2014년 Charter. All rights reserved.
//

import Foundation
import XCTest
import Dionysus

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
    let workingChannel = "5"
    let workingDevice = "000004A8C1BE"
    let workingPassword = "Testing1"
    let workingUsername = "michudatest@charter.net"
    
    
    override func setUp() {
        super.setUp()
        
        //Setup a test config file
        let defaultConfig: NSDictionary = [kBaseURLKey: baseURL,
            kDefaultUsernameKey: username,
            kDefaultPasswordKey: password]
        defaultConfig.writeToFile(configPath, atomically: true)
        
        WebOperations.setConfiguration(configPath)
    }
    
    override func tearDown() {
        super.tearDown()
        
        //Remove the test config file
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        fileManager.removeItemAtPath(configPath, error: &error)
        
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
    }
    
    func testAuthorizedRequest() {
        //This is an integration test
        //  Set default config path so the operation hits real services
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        
        //Remove the key to force login
        userDefaults.removeObjectForKey(kAuthTokenKey)
        
        WebOperations.authorizedRequest() {
            let token = self.userDefaults.valueForKey(kAuthTokenKey) as? String
            XCTAssertNotNil(token, "Auth Token cannot be nil after authorized request completes")
        }
    }
    
    func testAuthToken() {
        //Get Old token
        let oldToken = userDefaults.valueForKey(kAuthTokenKey) as? String
        
        //Alter authToken in userDefaults
        let testToken = "TOKEN"
        userDefaults.setValue(testToken, forKey: kAuthTokenKey)
        
        //Make sure the token we set gets returned
        let token = WebOperations.authToken()
        XCTAssert(token == testToken, "Token must be value found in userDefaults")
        
        //Reset token back to old token
        userDefaults.setValue(oldToken, forKey:kAuthTokenKey)
    }
    
    func testBaseURL() {
        XCTAssert(WebOperations.baseURL() == baseURL, "BaseURL return must equal that of the config file")
    }
    
    func testChannelsListURL() {
        XCTAssert(WebOperations.channelsListURL() == (WebOperations.baseURL() + kLineupsEndpoint), "Channels List URL must be combination of baseURL and lineups endpoint")
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
    
    func testDevicesListURL() {
        XCTAssert(WebOperations.devicesListURL() == (WebOperations.baseURL() + kDevicesEndpoint), "Devices List URL must be combination of baseURL and devices endpoint")
    }
    
    func testFetchDevices() {
        //This is an integration test
        //  Set default config path so the operation hits real services
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        
        var connectExp = expectationWithDescription("Fetch Devices Success Test")
        func success(request: NSURLRequest, deviceList: [Device]!) {
            XCTAssertNotNil(deviceList, "Should have recieved an array, even if it is empty")
            connectExp.fulfill()
        }
        
        func failure(request: NSURLRequest, error: NSError) {
            connectExp.fulfill()
        }
        
        WebOperations.fetchDevices(success, failure: failure)
        
        waitForExpectationsWithTimeout(60) { (error: NSError!) in
            XCTAssert(true, "Fetch Devices timed out")
        }
    }
    
    func testFetchChannels() {
        //This is an integration test
        //  Set default config path so the operation hits real services
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        
        var connectExp = expectationWithDescription("Fetch Devices Success Test")
        func success(request: NSURLRequest, channelList: [Channel]!) {
            XCTAssertNotNil(channelList, "Should have recieved an array, even if it is empty")
            connectExp.fulfill()
        }
        
        func failure(request: NSURLRequest, error: NSError) {
            connectExp.fulfill()
        }
        
        WebOperations.fetchChannels(success, failure: failure)
        
        waitForExpectationsWithTimeout(60) { (error: NSError!) in
            XCTAssert(true, "Fetch Channels timed out")
        }
    }
    
    func testLogin() {
        //This is an integration test
        //  Set default config path so the operation hits real services
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        
        var failExp = expectationWithDescription("Login Fail Test")
        func failure(request: NSURLRequest, error: NSError!) {
            XCTAssertNotNil(error, "Should have recieved data")
            
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
            
            if let errorInfo = error.userInfo  {
                if let json = errorInfo[kErrorResponseKey] as? NSDictionary {
                    XCTAssertNotNil(json["Code"], "Failed Login JSON must have a Code")
                }
            }
            
            failExp.fulfill()
        }
        
        var succExp = expectationWithDescription("Login Success Test")
        func success(request: NSURLRequest, token: String!) {
            XCTAssertNotNil(token, "Should have recieved a token")
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
    
    func testSetAuthToken() {
        //Get Old token
        let oldToken = userDefaults.valueForKey(kAuthTokenKey) as? String
        
        //Setup a test token
        let testToken = "TOKEN"
        WebOperations.setAuthToken(testToken)
        
        let token = userDefaults.valueForKey(kAuthTokenKey) as String
        
        XCTAssertNotNil(token, "Value for kAuthTokenKey cannot be nil after setting it")
        XCTAssert(token == testToken, "Token must be value found in userDefaults")
        
        //Reset token back to old token
        userDefaults.setValue(oldToken, forKey:kAuthTokenKey)
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
    
    func testTuneDictionary() {
        let macAddress = "YourMomsMacAddress"
        let channel = "Channel7"
        
        //Get a tune dictionary
        let tuneDict = WebOperations.tuneDictionary(channel, macAddress: macAddress)
        
        //Make sure its in a root dictionary
        XCTAssertNotNil(tuneDict[kControlPlaneRequestKey], "Tune dictionary must have a root dictionary under the control plane request key")
        let rootDict = tuneDict[kControlPlaneRequestKey] as NSDictionary
        
        //Check mac address
        XCTAssert(rootDict[kMacAddressKey] as? String == macAddress, "MacAddress has to be equal to value passed in")
        
        //Check channel
        XCTAssert(rootDict[kChannelKey] as? String == channel, "Channel has to be equal to value passed in")
        
        //Check it is a tune action
        XCTAssert(rootDict[kActionKey] as? String == "tune", "Action must be tune")
    }
    
    func testTuneToChannel() {
        //This is an integration test
        //  Set default config path so the operation hits real services
        WebOperations.setConfiguration(WebOperations.defaultConfigPath())
        
        //Operation should return a success
        var connectExp = expectationWithDescription("Tune Channel Success Test")
        func success(request: NSURLRequest, successful: Bool!) {
            XCTAssert(successful == true, "Did not successfully tune to channel")
            
            connectExp.fulfill()
        }
        
        func failure(request: NSURLRequest, error: NSError) {
            connectExp.fulfill()
        }
        
        WebOperations.tuneToChannel(workingChannel, deviceMacAddress: workingDevice, completion: success, failure: failure)
        
        waitForExpectationsWithTimeout(60) { (error: NSError!) in
            XCTAssert(true, "Tune to Channel timed out")
        }
    }
    
    func testTuneURL() {
        XCTAssert(WebOperations.tuneURL() == (WebOperations.baseURL() + kTuneChannelEndpoint), "Tune URL must be combination of baseURL and tune channel endpoint")
    }
    
    func testUserDefaultValue() {
        let value = "Your Mom"
        let key = "Your Mom Key"
        userDefaults.setValue(value, forKey: key)
        
        XCTAssert(WebOperations.userDefaultForKey(key) == value, "Value must equal value in userDefaults")
    }
}
