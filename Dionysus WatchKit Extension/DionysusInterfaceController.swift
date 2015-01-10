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
                        t.setRowTypes(["NumpadMenuRow", "FavoritesMenuRow"])
                }
                
                if let results = DataManager.sharedInstance.fetchResults("Channel", predicate: NSPredicate(format: "%K <= %@", kTitleEndDate, NSDate())) {
                        if results.count > 0 || Channel.allChannels().count == 0 {
                                println("Found out of date data, Refreshing...")
                                WebOperations.fetchChannels(nil, failure: nil)
                        } else {
                                println("All channel data is synced")
                        }
                }
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
        
        override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
                let notif = UILocalNotification()
                
                
                var assetData = NSData()
                if let url = NSURL(string: "http://tmsimg.video.cdn.charter.com/iconic/v9/AllPhotos/9087990/p9087990_i_v9_aa.jpg?width=\(self.contentFrame.size.width)") {
                        if let data = NSData(contentsOfURL: url) {
                                assetData = data
                        }
                }
                
                var networkData = NSData()
                if let url = NSURL(string: "http://tmsimg.video.cdn.charter.com/h3/NowShowing/18284/s18284_h3_aa.png?w=90") {
                        if let data = NSData(contentsOfURL: url) {
                                networkData = data
                        }
                }
                
                notif.userInfo = [ kTitleString : "Lincoln",
                        kEpisodeString : "",
                        kTimeString : "6:00 PM - 8:00 PM",
                        kDescriptionString: "With the nation embroiled in still another year with the high death count of Civil War, President Abraham Lincoln (Daniel Day-Lewis) brings the full measure of his passion, humanity and political skill to what would become his defining legacy: to end the war and permanently abolish slavery through the 13th Amendment. Having great courage, acumen and moral fortitude, Lincoln pushes forward to compel the nation, and those in government who oppose him, to aim toward a greater good for all mankind.",
                        kAssetImageData: assetData,
                        kNetworkImageData: networkData
                ]
                
                handleActionWithIdentifier(identifier, forLocalNotification: notif)
        }
        
        override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
                presentControllerWithName("AssetDetail", context: localNotification.userInfo)
        }
}
