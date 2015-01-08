//
//  ImageCacher.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 1/8/15.
//  Copyright (c) 2015 Charter. All rights reserved.
//

import WatchKit

/**
*       Helper class that provides functionality for caching image data from URLs. This class will clear the image cache if there isn't enough space to cache a new image.
*/
extension UIImage {
        /**
        Will return the UIImage stored under the URL input.
        
        :param: url The URL of the cached image to retrieve. If the app has not cached this URL image, it will download the contents and cache it for future use.
        
        :returns: The UIImage associated with the name input. If no image data is found, will return nil.
        */
        class func cachedImage(url: String!) -> UIImage? {
                var image: UIImage? = nil
                if let urlOfImage = NSURL(string: url) {
                        if let data = NSData(contentsOfURL: urlOfImage) {
                                if let img = UIImage(data: data) {
                                        image = img
                                }
                        }
                }

                if image != nil {
                        if WKInterfaceDevice.currentDevice().addCachedImage(image!, name: url) {
                                return image!
                        } else {
                                WKInterfaceDevice.currentDevice().removeAllCachedImages()
                                if WKInterfaceDevice.currentDevice().addCachedImage(image!, name: url) {
                                        return image!
                                }
                        }
                }
                
                return nil;
        }
}
