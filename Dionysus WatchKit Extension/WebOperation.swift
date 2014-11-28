//
//  WebOperation.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/7/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

public class WebOperation : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    lazy public var connection: NSURLConnection! = {
        let c = NSURLConnection(request: self.request, delegate: self, startImmediately: false)
        return c
    }()
    public var completionHandler: ((request: NSURLRequest, json: NSDictionary) -> Void)?
    public var failureHandler: ((request: NSURLRequest, error: NSError) -> Void)?
    lazy public var receivedData: NSMutableData = NSMutableData()
    lazy public var request: NSMutableURLRequest! = {
        let r = NSMutableURLRequest(URL: NSURL(string: self.urlString!)!)
        r.HTTPMethod = "GET"
        r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        r.setValue("application/json", forHTTPHeaderField: "Accept")
        r.setValue("authcookie=Spec2Jars!; ", forHTTPHeaderField:"Cookie")
        return r
    }()
    public var urlString: String?
    
    required public init(URL: String) {
        super.init()
        urlString = URL
    }
    
    //MARK: Initializers
    required convenience public init(URL: String, parameters: [String:String]?, data: [String:String]?, xmlDictionary: NSDictionary?) {
        self.init(URL: URL)
        
        if parameters != nil {
            let parameterString = WebOperation.queryString(parameters)
            urlString! += "?" + parameterString
        }
        
        if data != nil {
            let dataString = WebOperation.queryString(data)
            self.appendStringToData(dataString)
            request.HTTPMethod = "POST"
        }
        
        if xmlDictionary != nil {
            let dataString = xmlDictionary!.XML()
            self.appendStringToData(dataString)
            request.HTTPMethod = "POST"
        }
    }
    
    required convenience public init(URL: String, data: [String:String]?) {
        self.init(URL: URL, parameters: nil, data: data, xmlDictionary: nil)
    }
    
    required convenience public init(URL: String, parameters: [String:String]?) {
        self.init(URL: URL, parameters: parameters, data: nil, xmlDictionary: nil)
    }
    
    required convenience public init(URL: String, parameters: [String:String]?, xmlDictionary: NSDictionary?) {
        self.init(URL: URL, parameters: parameters, data: nil, xmlDictionary: xmlDictionary)
    }
    
    //MARK: Class functions
    public class func queryString(queries: [String:String]!) -> String! {
        var pString: String = String()
        for (key, value) in queries! {
            if pString.utf16Count != 0 {
                pString += "&"
            }
            pString += "\(key)=\(value)"
        }
        return pString
    }
    
    //MARK: Instance Operations
    public func appendStringToData(string: String!) {
        let mutableData = NSMutableData()
        mutableData.appendData(string.dataUsingEncoding(NSASCIIStringEncoding)!)
        
        if let currentBody = request.HTTPBody {
            mutableData.appendData(currentBody)
        }
        
        request.HTTPBody = mutableData
    }
    
    public func connect(completion: ((request: NSURLRequest, json: NSDictionary) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        completionHandler = completion
        failureHandler = failure
        connection.start()
    }
    
    //MARK: NSURLConnectionDataDelegate
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData.appendData(data)
    }
    
    //MARK: NSURLConnectionDelegate
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Connection Failed: \(error)")
        if failureHandler != nil {
            failureHandler!(request: connection.originalRequest, error: error)
        }
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        var error: NSError?
        
        let jsonData: AnyObject! = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.allZeros, error: &error)
        println("Connection Succeeded: \(jsonData)")
        if error == nil {
            if completionHandler != nil {
                completionHandler!(request: connection.originalRequest, json: jsonData as NSDictionary)
            }
        }
        
        receivedData = NSMutableData()
    }
}
