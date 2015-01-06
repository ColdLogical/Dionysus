//
//  DionysusXInterfaceController.swift
//  DionysusX
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit
import NotificationCenter

/**
*        Initial menu interface controller for watch application
*               Displays a menu to get to the various screens of the application
*/
class DionysusInterfaceController: WKInterfaceController {
        /// Interface Table for the menu
        @IBOutlet var table: WKInterfaceTable?
        
        /**
        Override of default init function to set up menu rows and do initial fetch of channels to fill data
        
        :returns: configured DionysusInterfaceController with all the rows of the menu items configured
        */
        override init() {
                super.init()
                
                if let t = table {
                        t.setRowTypes(["RotaryMenuRow", "NumpadMenuRow", "FavoritesMenuRow", "SearchMenuRow"])
                }
                
                WebOperations.fetchChannels(nil, failure: nil)
        }
        
        //    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        //        switch rowIndex {
        //        case 0:
        //        case 1:
        //        case 2:
        //        }
        //        if let device = Device.defaultDevice() {
        //            WebOperations.tuneToChannel(favoriteChannels[rowIndex].number, deviceMacAddress: device.macAddress, completion: nil, failure: nil)
        //        } else {
        //            //TODO: Figure out if it is possible to have a default device... if so, need some type of notification telling user they need to set their device.
        //            //      If not, then assert in default device call on Device class
        //        }
        //    } 
}
