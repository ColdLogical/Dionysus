//
//  FavoriteChannelRow.swift
//  Dionysus
//q
//  Created by Bush, Ryan M on 12/5/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

/**
*       Interface table row object used for favorite channels
*/
class FavoriteChannelRow: NSObject {
        /// Local reference for the channel this row is displaying information about
        var channel: Channel? {
                didSet {
                        titleLabel!.setText(channel!.valueForKey(kTitle) as? String)
                        episodeLabel!.setText(channel!.episodeText())
                        timeLabel!.setText(channel!.timeText())
                        if let uri = channel!.networkImageURIWithWidth(90) {
                                networkImage!.setImage(UIImage(data:NSData(contentsOfURL: NSURL(string: uri )!)!))
                        }
                }
        }
        
        /// Outlet to the episode WKInterfaceLabel object
        @IBOutlet var episodeLabel: WKInterfaceLabel?
        /// Outlet to the network WKInterfaceImage object
        @IBOutlet var networkImage: WKInterfaceImage?
        /// Outlet to the time WKInterfaceLabel object
        @IBOutlet var timeLabel: WKInterfaceLabel?
        /// Outlet to the title WKInterfaceLabel object
        @IBOutlet var titleLabel: WKInterfaceLabel?
}
