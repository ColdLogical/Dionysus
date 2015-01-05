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
public let kLineupsEndpoint = "symphony/services/v1/catalog/video/guide"
public let kTitleDetailsEndpoint = "symphony/services/v1/catalog/video/titles/"
public let kTokenKey = "token"
public let kTuneChannelEndpoint = "symphony/services/v1/devices"
public let kPasswordKey = "password"
public let kUserDefaultsSuiteName = "group.com.charter.dionysus"
public let kUsernameKey = "username"

let DataOperationClass = WebOperation.self

/**
This class provides an abstraction to the web services and user default suite.

Helper methods are provided to be able to easily access the configurable options such as the authorization token or base URL. There are abstracted web operation functions that deal with connecting to the correct endpoints and parsing the resulting json data into the correct objects.

All end point touching operations should accept a completion and failure handler to be able to inform the requesting object with the correct information.
*/
public class WebOperations {
        /**
        Makes sure that there is a authorization token before calling the inputted function
        
        :param: loggedIn A function to call after a token has been found
        */
        public class func authorizedRequest(loggedIn: (()-> Void)!) {
                if WebOperations.authToken() != nil {
                        loggedIn()
                } else {
                        println("No auth token found while trying to do an authorized request")
                        
                        func loginCompletion(request: NSURLRequest, token: String!)  {
                                loggedIn()
                        }
                        
                        func loginFailure(request: NSURLRequest, error: NSError) {
                                loggedIn()
                        }
                        
                        WebOperations.login(loginCompletion, failure: loginFailure)
                }
        }
        
        /**
        Returns the authorization token from the user default suite
        
        :returns: String representation of the authorization token found in the user default suite
        */
        public class func authToken() -> String? {
                return WebOperations.userDefaultForKey(kAuthTokenKey)
        }
        
        /**
        Generates the base URL by checking the user default suite. If none is found, it will check the configuration file. If no base URL can be found, an assert will crash the program. No base URL means no web operations at all.
        
        :returns: String representation of the full tune URL.
        */
        public class func baseURL() -> String {
                //Check to see if defaults was changed previously
                //  This provides the ability to change it in code as well as via a config file
                if let nonDefaultURL = WebOperations.userDefaultForKey(kBaseURLKey) {
                        return nonDefaultURL
                }
                
                if let baseURL = WebOperations.configuration()[kBaseURLKey]  as? String {
                        return baseURL
                }
                
                assert(false, "No Base URL Found")
                return ""
        }
        
        /**
        Generates the channel URL by combining the base URL and the channel endpoint.
        
        :returns: String representation of the full channel URL.
        */
        public class func channelsListURL() -> String {
                return WebOperations.baseURL() + kLineupsEndpoint
        }
        
        /**
        Generates the configuration dictionary from the configuration path in the user default suite. If none is found, it will use the default configuration path. If no configuration is found at all, everything is broken, and an assert will crash the app.
        
        :returns: A dictionary with configuration values.
        */
        public class func configuration() -> NSDictionary! {
                var pathToConfig = WebOperations.defaultConfigPath()
                
                if let configPath = WebOperations.userDefaultForKey(kConfigPathKey)  {
                        pathToConfig = configPath
                }
                
                if let config = NSDictionary(contentsOfFile: pathToConfig) {
                        return config
                }
                
                //If no configuration dictionary is found, EVERYTHING IS BROKEN!!! (ÒДÓױ)
                assert(false, "No Configuration Dictionary found at \(pathToConfig)")
                return NSDictionary()
        }
        
        /**
        Generates the path to the default configuration file. Which is a plist file in the bundle named "DionysusConfig.plist".
        
        :returns: A string path pointing DionysusConfig.plist in the bundle.
        */
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
        
        /**
        Generates the device list URL by combining the base URL and the device list endpoint.
        
        :returns: String representation of the full device list URL.
        */
        public class func devicesListURL() -> String {
                return WebOperations.baseURL() + kDevicesEndpoint
        }
        
        /**
        Generates a dictionary from a plist file that is found in bundle.
        
        :param: plistName The name of the plist file, without the ".plist" extension.
        
        :returns: A dictionary with the contents of the plist file
        */
        public class func dictionaryFromPlistNamed(plistName: String!) -> NSDictionary? {
                return NSDictionary(contentsOfFile: WebOperations.plistFileNamed(plistName)!)
        }
        
        /**
        Generates the favorites URL by combining the base URL and the favorites endpoint.
        
        :returns: String representation of the full favorites URL.
        */
        public class func favoritesURL() -> String {
                return WebOperations.baseURL() + kFavoritesEndpoint
        }
        
        /**
        Web operation that fetches the channel line up for a user. The app must have an authorization token for this to work, so the app will attempt to get one if it doesn't have one already. This function will handle the parsing of the JSON from the web services into Channel objects
        
        :param: completion The completion handler. This function will pass in an array of the channels that were found.
        :param: failure    The failure handler
        */
        public class func fetchChannels(completion: ((request: NSURLRequest, channelList: [Channel]!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                authorizedRequest() {
                        if let auth = WebOperations.authToken() {
                                let url = WebOperations.channelsListURL()
                                let params = [kTokenKey : auth]
                                
                                let op: WebOperation = DataOperationClass(URL: url, parameters: params)
                                
                                func channelCompletion(request: NSURLRequest, json: NSDictionary!) {
                                        var channels = [Channel]()
                                        
                                        //JSON can have 0 channels
                                        if let guidePeriod = json["GuidePeriod"] as? NSArray {
                                                for dict in guidePeriod {
                                                        if let channelLineupArray = dict["ChannelLineup"] as? NSArray {
                                                                for channelInfoDict in channelLineupArray {
                                                                        var c = Channel.existingOrNewFromDictionary(channelInfoDict as NSDictionary)
                                                                        channels.append(c)
                                                                }
                                                        }
                                                }
                                        }
                                        
                                        if completion != nil {
                                                completion!(request: request, channelList: channels)
                                        }
                                }
                                
                                op.connect(channelCompletion, failure:failure)
                        } else {
                                if failure != nil {
                                        failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No auth token found while trying to fetch channel list"]))
                                }
                        }
                }
        }
        
        /**
        Web operation that fetches the devices for a user. The app must have an authorization token for this to work, so the app will attempt to get one if it doesn't have one already. This function will handle the parsing of the JSON from the web services into Device objects
        
        :param: completion The completion handler. This function will pass in an array of the devices that were found.
        :param: failure    The failure handler
        */
        public class func fetchDevices(completion: ((request: NSURLRequest, deviceList: [Device]!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                authorizedRequest() {
                        if let auth = WebOperations.authToken() {
                                let url = WebOperations.devicesListURL()
                                let params = [kTokenKey : auth]
                                
                                let op: WebOperation = DataOperationClass(URL: url, parameters: params)
                                
                                func deviceCompletion(request: NSURLRequest, json: NSDictionary!) {
                                        var devices = [Device]()
                                        
                                        //JSON can have 0 devices
                                        if let devicesJSON = json["Devices"] as? NSDictionary {
                                                if let deviceList = devicesJSON["Device"] as? NSArray {
                                                        for dict in deviceList {
                                                                var d = Device.existingOrNewFromDictionary(dict as NSDictionary)
                                                                devices.append(d)
                                                        }
                                                }
                                        }
                                        
                                        if completion != nil {
                                                completion!(request: request, deviceList: devices)
                                        }
                                }
                                
                                op.connect(deviceCompletion, failure:failure)
                        } else {
                                if failure != nil {
                                        failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No auth token found while trying to fetch device list"]))
                                }
                        }
                }
        }
        
        /**
        Web operation that fetches the favorite channels for a user. The app must have an authorization token for this to work, so the app will attempt to get one if it doesn't have one already. This function will handle the parsing of the JSON from the web services and mark the appropriate channel objects as favorites.
        
        :param: completion The completion handler. This function will pass in an array of the channels that are favorites that were found.
        :param: failure    The failure handler
        */
        public class func fetchFavorites(completion: ((request: NSURLRequest, favorites: [Channel]!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                authorizedRequest() {
                        if let auth = WebOperations.authToken() {
                                let url = WebOperations.favoritesURL()
                                let params = [kTokenKey : auth]
                                
                                let op: WebOperation = DataOperationClass(URL: url, parameters: params)
                                
                                func favoritesCompletion(request: NSURLRequest, json: NSDictionary!) {
                                        //Remove all the old favorites, because we are going to set everything we get to the new favorites
                                        for oldFavorite in Channel.allFavorites() {
                                                oldFavorite.setValue(false, forKey: kIsFavorite)
                                        }
                                        
                                        var favorites = [Channel]()
                                        
                                        //JSON can have 0 devices
                                        if let preferences = json["Preference"] as? NSArray {
                                                for dict in preferences {
                                                        if let channelIds = dict["Value"] as? String {
                                                                for cId in channelIds.componentsSeparatedByString(",") {
                                                                        var f = Channel.existingOrNew(cId)
                                                                        f.setValue(true, forKey: kIsFavorite)
                                                                        favorites.append(f)
                                                                }
                                                        }
                                                }
                                        }
                                        
                                        if completion != nil {
                                                completion!(request: request, favorites: favorites)
                                        }
                                }
                                
                                op.connect(favoritesCompletion, failure:failure)
                        } else {
                                if failure != nil {
                                        failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No auth token found while trying to fetch favorite channels"]))
                                }
                        }
                }
        }
        
        /**
        Fetchs the title details for the channel and updates the channels appropriate properties with the new information.
        
        :param: channel    The channel to get title details for. The channel will be updated with the information received from the server.
        :param: completion The completion handler. This function will pass success if it received title detail information from the server.
        :param: failure    The failure handler.
        */
        public class func fetchTitleDetails(channel: Channel!, completion: ((request: NSURLRequest, success: Bool!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                authorizedRequest() {
                        if let auth = WebOperations.authToken() {
                                if let titleId = channel.valueForKey(kTitleId) as? String {
                                        let url = WebOperations.titleDetailsURL(titleId)
                                        let params = [kTokenKey : auth]
                                        
                                        let op: WebOperation = DataOperationClass(URL: url, parameters: params)
                                        
                                        func titleDetailsCompletion(request: NSURLRequest, json: NSDictionary!) {
                                                if let contentArray = json["Content"] as? NSArray {
                                                        for contentDict in contentArray {
                                                                if let titleDict = contentDict["TitleItem"] as? NSDictionary {
                                                                        channel.setValue(titleDict["LongDescription"] as? String ?? "", forKey:kTitleDescription)
                                                                        
                                                                        if let imageArray = titleDict["Image"] as? NSArray {
                                                                                var smallestImageDict: NSDictionary?
                                                                                
                                                                                for imageDict in imageArray {
                                                                                        if smallestImageDict != nil {
                                                                                                if let smallestWidth = smallestImageDict!["Width"] as? NSNumber {
                                                                                                        if let width = imageDict["Width"] as? NSNumber {
                                                                                                                if smallestWidth.compare(width) == NSComparisonResult.OrderedDescending {
                                                                                                                        continue
                                                                                                                }
                                                                                                        } else {
                                                                                                                continue
                                                                                                        }
                                                                                                }
                                                                                                
                                                                                        }
                                                                                
                                                                                        smallestImageDict = imageDict as? NSDictionary
                                                                                }
                                                                                
                                                                                if smallestImageDict != nil {
                                                                                        channel.setValue(smallestImageDict!["ImageUri"] as? String ?? "", forKey:kTitleImage)
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                }
                                                
                                                if completion != nil {
                                                        completion!(request: request, success: true)
                                                }
                                        }
                                        
                                        op.connect(titleDetailsCompletion, failure:failure)
                                } else {
                                        
                                }
                        } else {
                                if failure != nil {
                                        failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No auth token found while trying to fetch title details"]))
                                }
                        }
                }
        }
        
        /**
        Convience method that calls login(username:, password:, completion:, failure:,) with the default login parameters.
        
        :param: completion The completion handler. This function will pass in the authorization token received.
        :param: failure    The failure handler.
        :seealso: login(username:, password:, completion:, failure:,)
        */
        public class func login(completion: ((request: NSURLRequest, token: String!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                let params = WebOperations.loginParameters()
                WebOperations.login(params[kUsernameKey]!, password: params[kPasswordKey]!, completion: completion, failure: failure)
        }
        
        /**
        Convience method that calls login(username:, password:, completion:, failure:,) with the input username and password as parameters.
        
        :param: completion The completion handler. This function will pass in the authorization token received.
        :param: failure    The failure handler.
        :seealso: login(completion:, failure:,)
        */
        public class func login(username: String, password: String, completion: ((request: NSURLRequest, token: String!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                let url = WebOperations.loginURL()
                let params = [kUsernameKey: username, kPasswordKey: password]
                
                let op: WebOperation = DataOperationClass(URL: url, parameters: params)
                op.request.HTTPMethod = "POST"
                
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
                
                op.connect(loginCompletion, failure:nil)
        }
        
        /**
        Generates a dictionary with the login parameters from the user default suite. If none are found, it searchs the configuration file for them. If still none are found, defaults are used from the constants kDefaultPassword and kDefaultUsername.
        
        :returns: A dictionary of the login parameters
        */
        public class func loginParameters() -> [String:String] {
                //TODO: check user default suite for login username and password before checking configuration dictionary
                
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
        
        /**
        Generates the login URL by combining the base URL and the login endpoint.
        
        :returns: String representation of the full login URL.
        */
        public class func loginURL( ) -> String {
                return WebOperations.baseURL() + kLoginEndpoint
        }
        
        /**
        Generates the path to the plist found with the input file name that is located in the bundle.
        
        :param: fileName The name of the plist file, without the ".plist" extension
        
        :returns: A path to the plist file
        */
        public class func plistFileNamed(fileName: String!) -> String? {
                return NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
        }
        
        /**
        Helper function that sets the authorization token into the user default suite.
        
        :param: newToken The new authorization token.
        */
        public class func setAuthToken(newToken: String?) {
                WebOperations.setUserDefault(newToken, key: kAuthTokenKey)
        }
        
        /**
        Helper function that sets the base URL in the user default suite.
        
        :param: newBaseURL The new base URL.
        */
        public class func setBaseURL(newBaseURL: String?) {
                WebOperations.setUserDefault(newBaseURL, key: kBaseURLKey)
                
                //Altering the base url invalidates the auth token, dont try to use it again
                WebOperations.setAuthToken(nil)
        }
        
        /**
        Helper function that sets the path to the configuration file in the user default suite
        
        :param: newPathToConfig The new path to the configuration file
        */
        public class func setConfiguration(newPathToConfig: String?) {
                WebOperations.setUserDefault(newPathToConfig, key: kConfigPathKey)
                
                //Upon setting a new configuration, need to reset baseURL from defaults to prevent corruption
                WebOperations.setBaseURL(nil)
        }
        
        /**
        Helper function that sets a value for the key in the user default suite. Only uses strings.
        
        :param: value The string value to set for the key
        :param: key   The key to save the value under
        */
        public class func setUserDefault(value: String?, key: String) {
                if let userDefaults = NSUserDefaults(suiteName: kUserDefaultsSuiteName) {
                        if value != nil {
                                userDefaults.setObject(value, forKey: key)
                        } else {
                                userDefaults.removeObjectForKey(key)
                        }
                        
                        return
                }
                
                assert(false, "User defaults could not be created for suit named \(kUserDefaultsSuiteName)")
        }
        
        /**
        Generates a title details URL by combining the base URL, the title details endpoint, and the title Id.
        
        :param: titleId The id of the title to get details for.
        */
        public class func titleDetailsURL(titleId: String!) -> String {
                return WebOperations.baseURL() + kTitleDetailsEndpoint + "/" + titleId
        }
        
        /**
        Tunes the default device to the inputted channel. Passes arguments along to the tuneToChannel(channel:,deviceMacAddress:,completion:, failure:) method, but with the default device retrived from the Device class.
        
        :param: channel    The channel ID to tune too
        :param: completion       The completion handler. This function will pass the success response received from the services.
        :param: failure    The failure handler
        */
        public class func tuneDefaultDevice(channel: String!, completion: ((request: NSURLRequest, successful: Bool!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                if let device =  Device.defaultDevice() {
                        WebOperations.tune(channel, deviceMacAddress: device.macAddress, completion: completion, failure: failure)
                } else {
                        if failure != nil {
                                println("No default device found, tune to default device failed")
                                failure!(request: NSURLRequest(), error:  NSError(domain: "Muldor", code: 404, userInfo: [ NSLocalizedDescriptionKey: "No default device found when trying to tune channel"]))
                        }
                }
        }
        
        /**
        Creates a dictionary with the correct keys and values structure to be converted to XML for the tune web operation.
        
        :param: channel    The channel ID to tune too
        :param: macAddress The device MAC address to tune
        
        :returns: A structured dictionary utilized for the tune web operation
        */
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
        
        /**
        Tunes the device with the inputted MAC address to the channel with the inputted channel ID.
        
        :param: channel          The channel ID to tune too
        :param: deviceMacAddress The MAC address of the device to tune
        :param: completion       The completion handler. This function will pass the success response received from the services.
        :param: failure          The failure handler
        */
        public class func tune(channel: String!, deviceMacAddress: String!, completion: ((request: NSURLRequest, successful: Bool!) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                if let auth = WebOperations.authToken() {
                        let params = [kTokenKey : auth]
                        let url = WebOperations.tuneURL()
                        let data = WebOperations.tuneDictionary(channel, macAddress: deviceMacAddress)
                        
                        let op = DataOperationClass(URL: url, parameters: params, xmlDictionary: data)
                        
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
                        
                        op.connect(tuneCompletion, failure: nil)
                } else {
                        println("No Auth Token found when trying to tune channel")
                        if failure != nil {
                                failure!(request: NSURLRequest(), error: NSError(domain: "Muldor", code: 1001, userInfo: [ NSLocalizedDescriptionKey: "No Auth Token found when trying to tune channel"]))
                        }
                }
        }
        
        /**
        Generates the tune URL by combining the base URL and the tune endpoint.
        
        :returns: String representation of the full tune URL.
        */
        public class func tuneURL() -> String {
                return WebOperations.baseURL() + kTuneChannelEndpoint
        }
        
        /**
        Returns the string for the key found in the user default suite
        
        :param: key The key to get the value of
        
        :returns: The value found for the key in the user default suite
        */
        public class func userDefaultForKey(key: String) -> String? {
                if let userDefaults = NSUserDefaults(suiteName: kUserDefaultsSuiteName) {
                        return userDefaults.stringForKey(key)
                }
                
                assert(false, "User defaults could not be created for suit named \(kUserDefaultsSuiteName)")
                return nil
        }
}
