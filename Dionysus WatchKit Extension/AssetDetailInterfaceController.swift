//
//  AssetDetailInterfaceController.swift
//  Dionysus
//
//  Created by Cold Logic on 1/2/15.
//  Copyright (c) 2015 Charter. All rights reserved.
//

import WatchKit

/**
*        Interface Controller for an asset to display all relavent information. Also allows for tuning to asset, recording asset, and opening asset on companion device.
*/
class AssetDetailInterfaceController: WKInterfaceController {
        /// Local reference to the channel this interface controller is displaying information about
        var channel: Channel? {
                didSet {
                        titleLabel!.setText(channel!.valueForKey(kTitle) as? String)
                        episodeLabel!.setText(channel!.episodeText())
                        timeLabel!.setText(channel!.timeText())
                        descriptionLabel!.setText(channel!.valueForKey(kTitleDescription) as? String)
                        
                        if let uri = channel!.networkImageURIWithWidth(90) {
                                networkImage!.setImage(UIImage(data:NSData(contentsOfURL: NSURL(string: uri )!)!))
                        }
                        
                        if let uri = channel!.assetImageURIWithWidth(Int(self.contentFrame.size.width)) {
                                networkImage!.setImage(UIImage(data:NSData(contentsOfURL: NSURL(string: uri )!)!))
                        }
                }
        }
        
        /// Outlet to the asset WKInterfaceImage object
        @IBOutlet var assetImage: WKInterfaceImage?
        /// Outlet to the description WKInterfaceLabel object
        @IBOutlet var descriptionLabel: WKInterfaceLabel?
        /// Outlet to the episode WKInterfaceLabel object
        @IBOutlet var episodeLabel: WKInterfaceLabel?
        /// Outlet to the network WKInterfaceImage object
        @IBOutlet var networkImage: WKInterfaceImage?
        /// Outlet to the time WKInterfaceLabel object
        @IBOutlet var timeLabel: WKInterfaceLabel?
        /// Outlet to the title WKInterfaceLabel object
        @IBOutlet var titleLabel: WKInterfaceLabel?
        
        // MARK: Operational Methods
        
        
        // MARK: Interface Actions
        /**
        Opens this asset detail on the companion device
        */
        @IBAction func open() {
                
        }
        
        /**
        Sends a record API call to record this asset
        */
        @IBAction func record() {
                
        }
        
        /**
        Sends a device tune API call to tune to this channel to watch the asset
        */
        @IBAction func watch() {
                
        }
         
}
