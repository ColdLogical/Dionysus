//
//  WebOperations.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 2014. 11. 12..
//  Copyright (c) 2014년 Charter. All rights reserved.
//

import Foundation

public let kAuthTokenKey = "AuthToken"
public let kBaseURLKey = "BaseURL"
public let kConfigPathKey = "ConfigPath"
public let kControlPlaneRequestKey = "ControlPlaneRequest"
public let kDefaultBaseURL = "https://ctva.prd-aws.charter.net/api/"
public let kDefaultPasswordKey = "DefaultPassword"
public let kDefaultPassword = "Testing1" //"eXsC5s87r2vM"
public let kDefaultUsernameKey = "DefaultUsername"
public let kDefaultUsername = "michudatest@charter.net" //"coldlogic@charter.net"
public let kDevicesEndpoint = "symphony/services/v1/devices"
public let kErrorResponseKey = "ErrorReponse"
public let kFavoritesEndpoint = "symphony/services/v1/preferences/__FavoriteChannels__"
public let kLoginEndpoint = "symphony/auth/login"
public let kTokenKey = "token"
public let kTuneChannelEndpoint = "symphony/services/v1/devices"
public let kPasswordKey = "password"
public let kUsernameKey = "username"

let DataOperationClass = WebOperation.self

public class WebOperations {
    public class func authToken() -> String? {
        return WebOperations.userDefaultForKey(kAuthTokenKey)
    }

    public class func baseURL() -> String {
        //Check to see if defaults was changed previously
        //  This provides the ability to change it in code as well as via a config file
        if let nonDefaultURL = WebOperations.userDefaultForKey(kBaseURLKey) {
            return nonDefaultURL
        }
        
        if let baseURL = WebOperations.configuration()[kBaseURLKey]  as? String {
            return baseURL
        }
        
        assert(true, "No Base URL Found")
        return ""
    }
    
    public class func configuration() -> NSDictionary! {
        //Get default path to config file
        var pathToConfig = WebOperations.defaultConfigPath()
        
        //Check to see if the default config was overridden
        let userDefaults = NSUserDefaults()
        if let configPath = userDefaults.valueForKey(kConfigPathKey) as? String {
            //Set path to overridden config
            pathToConfig = configPath
        }
        
        //Return config
        if let config = NSDictionary(contentsOfFile: pathToConfig) {
            return config
        }
        
        //If no configuration dictionary is found, EVERYTHING IS BROKEN!!! (ÒДÓױ)
        assert(true, "No Configuration Dictionary found at \(pathToConfig)")
        return NSDictionary()
    }
    
    public class func defaultConfigPath() -> String! {
        //Get path to default config file
        var path = NSBundle.mainBundle().pathForResource("DionysusConfig", ofType: "plist")
        
        if path == nil {
            //No config file was found, so we need to create a default one
            let defaultConfig: NSDictionary = [kBaseURLKey: kDefaultBaseURL,
                kDefaultUsernameKey: kDefaultUsername,
                kDefaultPasswordKey: kDefaultPassword]
            
            let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docDirectory: String! = paths[0]  as String
            path = docDirectory.stringByAppendingPathComponent("DionysusConfig.plist")
            
            defaultConfig.writeToFile(path!, atomically: true)
        }
        
        return path
    }
    
    public class func devicesListURL() -> String {
        return WebOperations.baseURL() + kDevicesEndpoint
    }
    
    public class func dictionaryFromPlistNamed(plistName: String!) -> NSDictionary? {
        return NSDictionary(contentsOfFile: WebOperations.plistFileNamed(plistName)!)
    }
    
    public class func fetchDevices(completion: ((request: NSURLRequest, deviceList: [Device]!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        if let auth = WebOperations.authToken() {
            let url = WebOperations.devicesListURL()
            let params = [kTokenKey : auth]
            
            let devicesOp: WebOperation = DataOperationClass(URL: url, parameters: params)
            
            func deviceCompletion(request: NSURLRequest, json: NSDictionary!) {
                var devices = [Device]()
                
                //JSON can have 0 devices
                if let devicesJSON = json["Devices"] as? NSDictionary {
                    if let deviceList = devicesJSON["Device"] as? NSArray {
                        println("deviceList = \(deviceList)")
                        for dict in deviceList {
                            println("dict = \(dict)")
                            var d = Device.existingOrNewFromDictionary(dict as NSDictionary)
                            devices.append(d)
                        }
                    }
                }
                
                if completion != nil {
                    completion!(request: request, deviceList: devices)
                }
            }
            
            devicesOp.connect(deviceCompletion, failure:failure)
        } else {
            println("No auth token found while trying to fetch device list")
            if failure != nil {
                failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No auth token found while trying to fetch device list"]))
            }
        }
    }
    
    public class func login(completion: ((request: NSURLRequest, token: String!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        let params = WebOperations.loginParameters()
        WebOperations.login(params[kUsernameKey]!, password: params[kPasswordKey]!, completion: completion, failure: failure)
    }
    
    public class func login(username: String, password: String, completion: ((request: NSURLRequest, token: String!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        let url = WebOperations.loginURL()
        let params = [kUsernameKey: username, kPasswordKey: password]
        
        let loginOp: WebOperation = DataOperationClass(URL: url, parameters: params)
        loginOp.request.HTTPMethod = "POST"
        
        func loginCompletion(request: NSURLRequest, json: NSDictionary!) {
            var data: NSDictionary = json as NSDictionary
            
            //A valid successful login response will have a AuthResponse dictionary
            if let authorized = data["AuthResponse"] as? NSDictionary {
                if let token = authorized["Token"] as? String {
                    WebOperations.setAuthToken(token)
                    if completion != nil {
                         completion!(request: request, token: token)
                    }
                } else {
                    println("No Token in JSON data with request = \(request)\n\(json)")
                }
            } else {
                //If there is no Auth Response, then its probably an error 。・゜・(ノД`)・゜・。
                WebOperations.setAuthToken(nil)
                if let error = data["Error"]  as? NSArray {
                    if let errorDict = error[0] as? NSDictionary {
                        if failure != nil {
                            let error = NSError(domain: "Muldor", code: 1002, userInfo: [ NSLocalizedDescriptionKey: "Services returned an error", kErrorResponseKey: errorDict])
                            failure!(request: request, error: NSError(domain: "Muldor", code: 1002, userInfo: errorDict));
                        }
                    }
                }
            }
        }
        
        loginOp.connect(loginCompletion, failure:nil)
    }
    
    public class func loginParameters() -> [String:String] {
        //Get configuration dictionary
        if let configDict = WebOperations.configuration() {
            var params: [String:String] = [String:String]()
            
            //Pull out the username
            if let defaultUsername = configDict.valueForKey(kDefaultUsernameKey) as? String {
                params[kUsernameKey] = defaultUsername
            }
            
            //Pull out the password
            if let defaultPassword = configDict.valueForKey(kDefaultPasswordKey) as? String {
                params[kPasswordKey] = defaultPassword
            }
            
            //Only return these values if there is both a username and password
            if(params.keys.array.count == 2) {
                //Return the values
                return params
            }
        }
        
        println("No username or password was found in configuration file, using defaults")
        return [kPasswordKey: kDefaultPassword, kUsernameKey: kDefaultUsername]
    }
    
    public class func loginURL( ) -> String {
        return WebOperations.baseURL() + kLoginEndpoint
    }
    
    public class func plistFileNamed(fileName: String!) -> String? {
        return NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
    }
    
    public class func setAuthToken(newToken: String?) {
        WebOperations.setUserDefault(newToken, key: kAuthTokenKey)
    }
    
    public class func setBaseURL(newBaseURL: String?) {
        WebOperations.setUserDefault(newBaseURL, key: kBaseURLKey)
    }
    
    public class func setConfiguration(newPathToConfig: String?) {
        WebOperations.setUserDefault(newPathToConfig, key: kConfigPathKey)
        
        //Upon setting a new configuration, need to reset baseURL from defaults to prevent corruption
        WebOperations.setBaseURL(nil)
    }
    
    public class func setUserDefault(value: String?, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if value != nil {
            userDefaults.setObject(value, forKey: key)
        } else {
            userDefaults.removeObjectForKey(key)
        }
    }
    
    public class func tuneDictionary(channel: String!, macAddress: String!) -> NSDictionary! {
        //Example XML:
        //    <ControlPlaneRequest>
        //        <MacAddress>0000010D32F9</MacAddress>
        //        <Action>tune</Action>
        //        <Channel>742</Channel>
        //    </ControlPlaneRequest>
        
        return [kControlPlaneRequestKey:
            [ kMacAddressKey: macAddress,
                  kActionKey: "tune",
                 kChannelKey: channel ]]
    }
    
    public class func tuneToChannel(channel: String!, deviceMacAddress: String!, completion: ((request: NSURLRequest, successful: Bool!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        if let auth = WebOperations.authToken() {
            let params = [kTokenKey : auth]
            let url = WebOperations.tuneURL()
            let data = WebOperations.tuneDictionary(channel, macAddress: deviceMacAddress)
            
            let tuneOp = DataOperationClass(URL: url, parameters: params, xmlDictionary: data)
            
            func tuneCompletion(request: NSURLRequest, json: NSDictionary!) {
                var result = false
                
                if let code = json["Code"] as? String {
                    if code == "Ok" {
                        result = true
                    }
                }
                
                if completion != nil {
                    completion!(request: request, successful: result)
                }
            }
            
            tuneOp.connect(tuneCompletion, failure: nil)
        } else {
            println("No Auth Token found when trying to tune channel")
            if failure != nil {
                failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No Auth Token found when trying to tune channel"]))
            }
        }
    }
    
    public class func tuneURL() -> String {
        return WebOperations.baseURL() + kTuneChannelEndpoint
    }
    
    public class func userDefaultForKey(key: String) -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.stringForKey(key)
    }
}
