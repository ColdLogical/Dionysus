//
//  ImageCache.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 1/9/15.
//  Copyright (c) 2015 Charter. All rights reserved.
//

import Foundation
import CoreData

public let kImageCache = "ImageCache"
public let kKey = "key"
public let kUsedCount = "usedCount"
public let kUsedDate = "usedDate"

@objc(ImageCache)
/**
*       Managed Object that represents the associated data with an image cache such as the count of the times it has been used or the date it was last used.
*/
public class ImageCache: NSManagedObject {
        /// The number of times this image has been used
        @NSManaged public var usedCount: NSNumber
        /// The last date this image was used
        @NSManaged public var usedDate: NSDate
        /// The key of the image in the cache
        @NSManaged public var key: String
        
        /**
        Deletes a specific image cache from the managed object context.
        
        :param: imageCache The specific image cache to delete.
        */
        public class func deleteImageCache(imageCache: ImageCache!) {
                DataManager.sharedInstance.delete(imageCache)
        }
        
        /**
        Helper function to create an image cache based on the key.
        
        :param: key The URL key of the image.
        
        :returns: An image cache object with a matching key.
        */
        public class func existingOrNew(key: String!) -> ImageCache {
                let ic = DataManager.sharedInstance.existingOrNewEntity(kImageCache, predicate: NSPredicate(format: "%K = %@", kKey, key)) as ImageCache
                
                if ic.valueForKey(kKey) as? String != key {
                        ic.key = key
                        DataManager.sharedInstance.save()
                }
                
                return ic
        }
}