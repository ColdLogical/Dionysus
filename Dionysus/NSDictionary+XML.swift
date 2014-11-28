//
//  NSDictionary+XML.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/26/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

public let kXMLHeader = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd\">"

public extension NSDictionary {
    public func XML() -> String {
        var xml = self.XMLOfValues()
        
        if !xml.isEmpty {
            xml = kXMLHeader + xml
        }
        
        assert(xml.isEmpty == false, "XML representation cannot be empty")
        return xml
    }
    
    
    public func XMLOfValues() -> String {
        var xml = String()
        for (key, value) in self {
            //At the lowest point, final value will be a string
            var finalValue: AnyObject = value
            
            //If the value is a dictionary, then we need to recursively call this function
            if (value is NSDictionary || value is [String:String]) {
                finalValue = value.XMLOfValues()
            }
            
            xml += "<\(key)>\(finalValue)</\(key)>"
        }
        
        assert(xml.isEmpty == false, "XML representation cannot be empty")
        return xml
    }
}