//
//  FavoriteChannelRow.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 12/5/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

/**
*       Interface table row object used for favorite channels
*/
class FavoriteChannelRow: NSObject {
        /// Outlet to network WKInterfaceImage object
        @IBOutlet  var networkImage: WKInterfaceImage?
        /// Outlet to episode WKInterfaceLabel object
        @IBOutlet  var episodeLabel: WKInterfaceLabel?
        /// Outlet to time WKInterfaceLabel object
        @IBOutlet  var timeLabel: WKInterfaceLabel?
        /// Outlet to title WKInterfaceLabel object
        @IBOutlet  var titleLabel: WKInterfaceLabel?
}
