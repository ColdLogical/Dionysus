//
//  MenuRow.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 12/15/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

/**
*      Row for WKInterfaceTable that has an image and title. Used for the menu of the application
*/
class MenuRow: NSObject {
        /// Outlet to icon WKInterfaceImage object
        @IBOutlet  var iconImage: WKInterfaceImage?
        /// Outlet to title WKInterfaceLabel object
        @IBOutlet  var titleLabel: WKInterfaceLabel?
}