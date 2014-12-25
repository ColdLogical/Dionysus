//
//  NSDictionary+XML.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/26/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation

/**
*       NSDictionary extension that facilitates creating XML from the keys and values
*/
public extension NSDictionary {
        /**
        Returns the XML string representation of the keys and values. This function validates that there is a non-blank XML representation
        
        :returns: non-empty XML formatted string of keys and valnues
        */
        public func XML() -> String {
                var xml = self.XMLOfValues()
                
                assert(xml.isEmpty == false, "XML representation cannot be empty")
                return xml
        }
        
        /**
        Recursive function that continuously appends XML header tags, values, and closing tags of the keys and values of the dictionary
        
        :returns: XML formatted string of keys and values
        */
        public func XMLOfValues() -> String {
                var xml = String()
                for (key, value) in self {
                        var finalValue: AnyObject = value
                        
                        if (value is NSDictionary || value is [String:String]) {
                                finalValue = value.XMLOfValues()
                        }
                        
                        xml += "<\(key)>\(finalValue)</\(key)>"
                }
                
                assert(xml.isEmpty == false, "XML representation cannot be empty")
                return xml
        }
}