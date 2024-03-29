//
//  FavoritesInterfaceController.swift
//  Dionysus
//
//  Created by  Bush, Ryan M on 12/5/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

/**
*       Interface controller for display of favorite channel info. When selecting a row, it tunes the default device to that channel
*/
class FavoritesInterfaceController: WKInterfaceController {
        /// Outlet to table for the interface controller
        @IBOutlet var table: WKInterfaceTable?
        
        /// Lazily loaded array of favorite channels
        lazy var favoriteChannels: [Channel] = Channel.allFavorites()
        
        /**
        Overrides the default implementation to fetch the list of favorite channels
        
        :returns: a new configured FavoritesInterfaceController
        */
        override init() {
                super.init()
                
                updateRows()
                WebOperations.fetchFavorites(updateRowsAfterFetch, failure: nil)
        }
        
         /**
        Updates the rows of the interface table with all the favorite channels information
        
        :param: request The NSURLRequest of the web operation
        :param: favorites The list of Channels received from the web operation
        */
        func updateRowsAfterFetch(request: NSURLRequest!, favorites: [Channel]!) {
                updateRows()
        }
        
        func updateRows() {
                if let t = table {
                        t.setNumberOfRows(self.favoriteChannels.count, withRowType: "FavoriteChannelRow")
                        
                        for i in 0 ..< t.numberOfRows {
                                if let  row = t.rowControllerAtIndex(i) as? FavoriteChannelRow {
                                        let favorite = self.favoriteChannels[i]
                                        row.channel = favorite
                                }
                        }
                }
        }
        
        //MARK: WKInterfaceTableDelegate Functions
        override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
                if let device = Device.defaultDevice() {
                        //NOTE: We assume this call always succeeds (cause we are moronic optimists), thus there is no implementation of completion or failure
                        WebOperations.tune(favoriteChannels[rowIndex].number, deviceMacAddress: device.macAddress, completion: nil, failure: nil)
                }
                //NOTE: It is technically possible to not have a default device. However, this should never happen with a valid Charter customer.
                //      Add code here to handle the user interface if we decide to handle the flow of not having a default device.
        }
}
