//
//  FavoritesInterfaceController.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 12/5/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

class FavoritesInterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable?
    
    lazy var favoriteChannels: [Channel] = Channel.allFavorites()
    
    override init(context: AnyObject?) {
        super.init(context: context)
        
        func completion(request: NSURLRequest!, favorites: [Channel]!) {
            if let t = table {
                t.setNumberOfRows(self.favoriteChannels.count, withRowType: "FavoriteChannelRow")
                
                for i in 0 ..< t.numberOfRows {
                    if let  row = t.rowControllerAtIndex(i) as? FavoriteChannelRow {
                        let favorite = self.favoriteChannels[i]
                        row.titleLabel!.setText(favorite.valueForKey(kTitle) as? String)
                        if var networkURI = favorite.valueForKey(kNetworkLogoURI) as? String {
                            let resizedURI: String = networkURI + "?w=90"
                            row.networkImage!.setImage(UIImage(data:NSData(contentsOfURL: NSURL(string: resizedURI )!)!))
                        }
                        
                        let seasonNumber = favorite.valueForKey(kSeasonNumber) as? String
                        let episodeNumber = favorite.valueForKey(kEpisodeNumber) as? String
                        let episodeTitle = favorite.valueForKey(kEpisodeTitle) as? String
                        
                        if seasonNumber != nil && episodeNumber != nil && episodeTitle != nil {
                            row.episodeLabel!.setText("(S\(seasonNumber!), E\(episodeNumber!)) \(episodeTitle!)")
                        } else {
                            row.episodeLabel!.setText("")
                        }
                        
                        if let startDate = favorite.valueForKey(kTitleStartDate) as? NSDate {
                            let formatter = NSDateFormatter()
                            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
                            
                            let startString = formatter.stringFromDate(startDate)
                            if let endDate = favorite.valueForKey(kTitleEndDate) as? NSDate {
                                let endString = formatter.stringFromDate(endDate)
                                row.timeLabel!.setText("\(startString) - \(endString)")
                            } else {
                                row.timeLabel!.setText("\(startString)")
                            }
                        } else {
                            row.timeLabel!.setText("")
                        }
                    }
                }
            }
        }
        
        WebOperations.fetchFavorites(completion, failure: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let device = Device.defaultDevice() {
            WebOperations.tuneToChannel(favoriteChannels[rowIndex].number, deviceMacAddress: device.macAddress, completion: nil, failure: nil)
        } else {
            //TODO: Figure out if it is possible to have a default device... if so, need some type of notification telling user they need to set their device.
            //      If not, then assert in default device call on Device class
        }
    }
    
    
}
