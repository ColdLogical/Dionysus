//
//  AssetDetailInterfaceController.swift
//  Dionysus
//
//  Created by Cold Logic on 1/2/15.
//  Copyright (c) 2015 Charter. All rights reserved.
//

import WatchKit

public let kAssetImageData = "AssetImageData"
public let kDescriptionString = "DescriptionString"
public let kEpisodeString = "EpisodeString"
public let kNetworkImageData = "NetworkImageData"
public let kTimeString = "TimeString"
public let kTitleString = "TitleString"

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
                                networkImage!.setImageNamed(DataManager.sharedInstance.cacheImage(uri))
                        }
                        
                        if let uri = channel!.assetImageURIWithWidth(90) {
                                assetImageGroup!.setBackgroundImageNamed(DataManager.sharedInstance.cacheImage(uri))
                        }
                }
        }
        
        /// NSDictionary that holds all information to be displayed on an asset detail interface controller. This is used to display information for notifications since the current information would be incorrect.
        var completeInfo: NSDictionary? {
                didSet {
                        titleLabel!.setText(completeInfo![kTitleString] as? String)
                        episodeLabel!.setText(completeInfo![kEpisodeString] as? String)
                        timeLabel!.setText(completeInfo![kTimeString] as? String)
                        descriptionLabel!.setText(completeInfo![kDescriptionString] as? String)
                        
                        if let image = UIImage(data: completeInfo![kAssetImageData] as NSData) {
                                assetImageGroup!.setBackgroundImage(image)
                        }
                        
                        if let image = UIImage(data: completeInfo![kNetworkImageData] as NSData) {
                                networkImage!.setImage(image)
                        }
                }
        }
        
        /**
        Float value representing the current progress displayed.
        
        This value is between 0.0 and 1.0, where 1.0 represents completion. Input values are pinned to those limits.
        */
        var progress: Float = 0.0 {
                didSet {
                        if progress > 1 {
                                progress = 1
                        } else if progress < 0 {
                                progress = 0
                        }
                        
                        if let pg = self.progressGroup {
                                let progressWholeNumber: CGFloat = CGFloat(progress) * self.contentFrame.size.width
                                pg.setWidth(progressWholeNumber)
                        }
                }
        }
        
        /// Outlet to the asset WKInterfaceImage object
        @IBOutlet var assetImageGroup: WKInterfaceGroup?
        /// Outlet to the description WKInterfaceLabel object
        @IBOutlet var descriptionLabel: WKInterfaceLabel?
        /// Outlet to the group used to display the emptyness
        @IBOutlet var emptynessGroup: WKInterfaceGroup?
        /// Outlet to the episode WKInterfaceLabel object
        @IBOutlet var episodeLabel: WKInterfaceLabel?
        /// Outlet to the network WKInterfaceImage object
        @IBOutlet var networkImage: WKInterfaceImage?
        /// Outlet to the group used to display the progress
        @IBOutlet var progressGroup: WKInterfaceGroup?
        /// Outlet to the time WKInterfaceLabel object
        @IBOutlet var timeLabel: WKInterfaceLabel?
        /// Outlet to the title WKInterfaceLabel object
        @IBOutlet var titleLabel: WKInterfaceLabel?
        
        /**
        Overides default implementation to provide support for context configuration
        
        :param: context The object used to configure the asset detail page. Can be a Channel object or an NSDictionary.
        */
        override func awakeWithContext(context: AnyObject?) {
                if let info = context  as? NSDictionary {
                        completeInfo = info
                }
                
                if let c = context as? Channel {
                        channel = c
                        
                        let description = c.valueForKey(kTitleDescription) as? String
                        if description == nil || description!.isEmpty {
//                                WebOperations.fetchTitleDetails(c, completion: nil, failure: nil)
                        }
                }
        }
        
        // MARK: Operational Methods
        /**
        Function that sets the right side color of the progress view.
        
        :param: color The color to display the emptyness in.
        */
        func setEmptyColor(color: UIColor) {
                if let eg = self.emptynessGroup {
                        eg.setBackgroundColor(color)
                }
        }
        
        /**
        Function that sets the left side color of the progress view.
        
        :param: color The color to display the progress in.
        */
        func setProgressColor(color: UIColor!) {
                if let pg = self.progressGroup {
                        pg.setBackgroundColor(color)
                }
        }
        
        
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
