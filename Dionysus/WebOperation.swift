//
//  WebOperation.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/7/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

class WebOperation : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    lazy var connection: NSURLConnection! = {
        let c = NSURLConnection(request: self.request, delegate: self, startImmediately: false)
        return c
    }()
    var completionHandler: ((request: NSURLRequest, json: NSDictionary) -> Void)?
    var failureHandler: ((request: NSURLRequest, error: NSError) -> Void)?
    lazy var receivedData: NSMutableData = NSMutableData()
    lazy var request: NSMutableURLRequest! = {
        let r = NSMutableURLRequest(URL: NSURL(string: self.urlString!)!)
        r.HTTPMethod = "GET"
        r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        r.setValue("application/json", forHTTPHeaderField: "Accept")
        r.setValue("authcookie=Spec2Jars!; ", forHTTPHeaderField:"Cookie")
        return r
    }()
    var urlString: String?
    
    init(URL: String) {
        super.init()
        urlString = URL
    }
    
    convenience init(URL: String, parameters: [String:String]?) {
        self.init(URL: URL)
        
        if parameters != nil {
            var pString: String = String()
            for (key, value) in parameters! {
                if pString.utf16Count != 0 {
                    pString += "&"
                }
                pString += "\(key)=\(value)"
            }
            request.HTTPBody = pString.dataUsingEncoding(NSASCIIStringEncoding)
        }
    }
    
    func connect(completion: ((request: NSURLRequest, json: NSDictionary) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
        completionHandler = completion
        failureHandler = failure
        connection.start()
    }
    
    //MARK: NSURLConnectionDataDelegate
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData.appendData(data)
    }
    
//    func connection(connection: NSURLConnection, bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
//
//    }
//    
//    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
//        
//    }
    
    //MARK: NSURLConnectionDelegate
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Connection Failed: \(error)")
        if failureHandler != nil {
            failureHandler!(request: connection.originalRequest, error: error)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
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
    
//    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
//
//    }
//    
//    func connectionShouldUseCredentialStorage(connection: NSURLConnection) -> Bool {
//        return true
//    }
//    
//    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
//        
//    }
//    
//    func connection(connection: NSURLConnection, needNewBodyStream request: NSURLRequest) -> NSInputStream? {
//        
//    }
//    
//    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
//        
//    }
}
