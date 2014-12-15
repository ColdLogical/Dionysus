//
//  DionysusXInterfaceController.swift
//  DionysusX
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit
import NotificationCenter

class DionysusInterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable?
    
    override init(context: AnyObject?) {
        super.init(context: context)

        if let t = table {
            t.setRowTypes(["RotaryMenuRow", "NumpadMenuRow", "FavoritesMenuRow", "SearchMenuRow"])
        }
        
        WebOperations.fetchChannels(nil, failure: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
