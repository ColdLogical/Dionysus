//
//  WebOperations.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 2014. 11. 12..
//  Copyright (c) 2014년 Charter. All rights reserved.
//

import Foundation

let kAuthTokenKey = "AuthToken"
let kBaseURLKey = "BaseURL"
let kConfigPathKey = "ConfigPath"
let kDefaultBaseURL = "http://ctva.engprod-charter.net/"
let kDefaultPasswordKey = "DefaultPassword"
let kDefaultPassword = "eXsC5s87r2vM"
let kDefaultUsernameKey = "DefaultUsername"
let kDefaultUsername = "coldlogic@charter.net"
let kDevicesEndpoint = "services/v1/devices"
let kFavoritesEndpoint = "services/v1/preferences/__FavoriteChannels__"
let kLoginEndpoint = "api/symphony/auth/login"
let kTuneChannelEndpoint = "symphony/services/v1/devices"
let kPasswordKey = "password"
let kUsernameKey = "username"

class WebOperations {
    class func authToken() -> String? {
        return WebOperations.userDefaultForKey(kAuthTokenKey)
    }

    class func baseURL() -> String {
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
    
    class func configuration() -> NSDictionary! {
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
    
    class func defaultConfigPath() -> String! {
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
    
    class func login(completion: ((request: NSURLRequest, json: NSDictionary!) -> Void)?, failure: ((request: NSURLRequest, json: NSDictionary!) -> Void)?) {
        let params = WebOperations.loginParameters()
        WebOperations.login(params[kUsernameKey]!, password: params[kPasswordKey]!, completion: completion, failure: failure)
    }
    
    class func login(username: String, password: String, completion: ((request: NSURLRequest, json: NSDictionary!) -> Void)?, failure: ((request: NSURLRequest, json: NSDictionary!) -> Void)?) {
        let url = WebOperations.loginURL()
        let params = [kUsernameKey: username, kPasswordKey: password];
        
        let op: WebOperation = WebOperation(URL: url, parameters: params)
        op.request.HTTPMethod = "POST"
        
        func loginCompletion(request: NSURLRequest, json: NSDictionary!) {
            var data: NSDictionary = json as NSDictionary
            
            //A valid successful login response will have a AuthResponse dictionary
            if let authorized = data["AuthResponse"] as? NSDictionary {
                if let token = authorized["Token"] as? String {
                    WebOperations.setAuthToken(token)
                    if completion != nil {
                         completion!(request: request, json: authorized)
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
                            failure!(request: request, json: errorDict)
                        }
                    }
                }
            }
        }
        
        op.connect(loginCompletion, failure:nil)
    }
    
    class func loginParameters() -> [String:String] {
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
    
    class func loginURL( ) -> String {
        return WebOperations.baseURL() + kLoginEndpoint
    }
    
    class func setAuthToken(newToken: String?) {
        WebOperations.setUserDefault(newToken, key: kAuthTokenKey)
    }
    
    class func setBaseURL(newBaseURL: String?) {
        WebOperations.setUserDefault(newBaseURL, key: kBaseURLKey)
    }
    
    class func setConfiguration(newPathToConfig: String?) {
        WebOperations.setUserDefault(newPathToConfig, key: kConfigPathKey)
        
        //Upon setting a new configuration, need to reset baseURL from defaults to prevent corruption
        WebOperations.setBaseURL(nil)
    }
    
    class func setUserDefault(value: String?, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if value != nil {
            userDefaults.setObject(value, forKey: key)
        } else {
            userDefaults.removeObjectForKey(key)
        }
    }
    
    class func userDefaultForKey(key: String) -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.stringForKey(key)
    }
}
