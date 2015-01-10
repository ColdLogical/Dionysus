 //
//  DataManager.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import WatchKit

/**
*       A single who is responsible for maintaining the core data context. Provides functionality for creating objects, deleting objects, and fetching objects.
*/
public class DataManager {
        /// Default lazily loaded persistent store implementation
        lazy public var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
                var coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                let url = self.applicationDocumentsDirectory().URLByAppendingPathComponent("Dionysus.sqlite")
                var error: NSError? = nil
                var failureReason = "There was an error creating or loading the application's saved data."
                
                if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                        var dict = [String: AnyObject]()
                        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                        dict[NSLocalizedFailureReasonErrorKey] = failureReason
                        dict[NSUnderlyingErrorKey] = error
                        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                        NSLog("Unresolved error \(error), \(error!.userInfo)")
                        abort()
                }
                
                return coordinator
                }()
        
        /// Default lazily loaded managed object context implementation
        lazy public var context: NSManagedObjectContext = {
                let coordinator = self.persistentStoreCoordinator
                var context = NSManagedObjectContext()
                context.persistentStoreCoordinator = coordinator
                return context
                }()
        
        /// Default lazily loaded managed object model implementation
        lazy public var managedObjectModel: NSManagedObjectModel = {
                let modelURL = NSBundle.mainBundle().URLForResource("DionysusModel", withExtension:"momd")!
                return NSManagedObjectModel(contentsOfURL: modelURL)!
                }()
        
         /// Base singleton shared instance implementation
        public class var sharedInstance: DataManager {
                struct Static {
                        static var instance: DataManager?
                        static var token: dispatch_once_t = 0
                }
                
                dispatch_once(&Static.token) {
                        Static.instance = DataManager()
                }
                
                return Static.instance!
        }
        
        /// Default application documents directory implementation
        func applicationDocumentsDirectory() -> NSURL {
                return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
        }
        
        /// Default save context implementation
        public func save() {
                var error: NSError?
                if context.hasChanges && !context.save(&error) {
                        println("Unresolved error \(error), \(error!.userInfo)")
                        abort()
                }
        }
        
        //MARK: Helper Functions
        /**
        Will cache the image data for the URL key passed in. This will clear space in the cache if there isn't enough space to cache a new image. To clear space, it prioritizes cached images based on number of times used and date since last use, the removes the lowest priority ones until there is enough space to cache.
        
        :param: url The URL of the cached image to retrieve. If the app has not cached this URL image, it will download the contents and cache it for future use.
        */
        public func cacheImage(url: String!) -> String? {
                var key = url.stringByReplacingOccurrencesOfString("/", withString: "")
                key = key.stringByReplacingOccurrencesOfString(".", withString: "")
                key = key.stringByReplacingOccurrencesOfString("?", withString: "")
                key = key.stringByReplacingOccurrencesOfString(":", withString: "")
                
                let pred = NSPredicate(format: "%K == %@", kKey, key)
                
                if let results = fetchResults("ImageCache", predicate: pred) {
                        var imgCache: ImageCache? = nil
                        if results.count == 0 {
                                var image: UIImage? = nil
                                if let urlOfImage = NSURL(string: url) {
                                        if let data = NSData(contentsOfURL: urlOfImage) {
                                                if let img = UIImage(data: data) {
                                                        image = img
                                                }
                                        }
                                }
                                
                                if image != nil {
                                        if !WKInterfaceDevice.currentDevice().addCachedImage(image!, name: key) {
                                                let countDesc = NSSortDescriptor(key: kUsedCount, ascending: true)
                                                let dateDesc = NSSortDescriptor(key: kUsedDate, ascending: false)
                                                
                                                let imgCaches = fetchResults("ImageCache", sortDescriptors:[countDesc, dateDesc]) as [ImageCache]
                                                
                                                for ic in imgCaches {
                                                        WKInterfaceDevice.currentDevice().removeCachedImageWithName(ic.valueForKey(kKey) as String)
                                                        ImageCache.deleteImageCache(ic)
                                                        if WKInterfaceDevice.currentDevice().addCachedImage(image!, name: key) {
                                                                break;
                                                        }
                                                }
                                        }
                                        
                                        imgCache = ImageCache.existingOrNew(key)
                                }
                        } else {
                                imgCache = results[0] as? ImageCache
                        }
                        
                        if imgCache != nil {
                                var count = (imgCache!.valueForKey(kUsedCount) as NSNumber).intValue
                                imgCache!.setValue(NSNumber(int:count+1), forKey:kUsedCount)
                                imgCache!.setValue(NSDate(), forKey:kUsedDate)
                                
                                save()
                                
                                return key
                        }
                }
                
                return nil
        }
//        public func cacheImage(url: String!) {
//                let pred = NSPredicate(format: "%K == %@", kKey, url)
//                
//                if let results = fetchResults("ImageCache", predicate: pred) {
//                        var imgCache: ImageCache? = nil
//                        if results.count == 0 {
//                                println("Caching image \(url)")
//                                var image: UIImage? = nil
//                                if let urlOfImage = NSURL(string: url) {
//                                        if let data = NSData(contentsOfURL: urlOfImage) {
//                                                if let img = UIImage(data: data) {
//                                                        image = img
//                                                }
//                                        }
//                                }
//                                
//                                if image != nil {
//                                        if !WKInterfaceDevice.currentDevice().addCachedImage(image!, name: url) {
//                                                let countDesc = NSSortDescriptor(key: kUsedCount, ascending: true)
//                                                let dateDesc = NSSortDescriptor(key: kUsedDate, ascending: false)
//                                                
//                                                let imgCaches = fetchResults("ImageCache", sortDescriptors:[countDesc, dateDesc]) as [ImageCache]
//                                                
//                                                for ic in imgCaches {
//                                                        WKInterfaceDevice.currentDevice().removeCachedImageWithName(ic.valueForKey(kKey) as String)
//                                                        ImageCache.deleteImageCache(ic)
//                                                        if WKInterfaceDevice.currentDevice().addCachedImage(image!, name: url) {
//                                                                break;
//                                                        }
//                                                }
//                                        }
//                                        
//                                        imgCache = existingOrNewEntity("ImageCache", predicate: pred) as? ImageCache
//                                }
//                        } else {
//                                println("Using cached image \(url)")
//                                imgCache = results[0] as? ImageCache
//                        }
//                        
//                        if imgCache != nil {
//                                var count = (imgCache!.valueForKey(kUsedCount) as NSNumber).intValue
//                                imgCache!.setValue(NSNumber(int:count++), forKey:kUsedCount)
//                                imgCache!.setValue(NSDate(), forKey:kUsedDate)
//                        }
//                }
//        }
        
        /**
        Helper function to delete an object from the context and save the change.
        
        :param: object The managed object to delete
        */
        public func delete(object: NSManagedObject!) {
                context.deleteObject(object)
                save()
        }
        
        /**
        Helper function to return an existing item, or create a new one, based on the predicate that specifies the unique identifier. If multiple objects are found with the same unique identifier, it will cause a crash. This was specifically intedend when designed.
        
        :param: entityName The type of managed object to return
        :param: predicate  The predicate that will uniquely identify the object
        
        :returns: A object of the entity type that matches the uniquely identified predicate query
        */
        public func existingOrNewEntity(entityName: String!, predicate: NSPredicate?) -> AnyObject! {
                let results = fetchResults(entityName, predicate: predicate)
                if results != nil {
                        if results!.count > 0 {
                                assert(results!.count == 1, "Cannot have multiple entities with same identifier")
                                return results![0]
                        }
                }
                
                return newEntity(entityName)
        }
        
        /**
        Convience function to fetch all objects of an entity type.
        
        :param: entityName The type of managed object to fetch
        
        :returns: An array of objects matching the entity type
        */
        public func fetchResults(entityName: String!) -> [AnyObject]? {
                return fetchResults(entityName, predicate: nil, sortDescriptors: nil)
        }
        
        /**
        Convience function to fetch results from the managed object context based on entity type, and a predicate of any kind.
        
        :param: entityName The type of managed object to fetch
        :param: predicate  The predicate describing the objects to fetch
        
        :returns: An array of objects matching the predicate
        */
        public func fetchResults(entityName: String!, predicate: NSPredicate?) -> [AnyObject]? {
                return fetchResults(entityName, predicate: predicate, sortDescriptors: nil)
        }
        
        /**
        Helper function to fetch sorted results from the managed object context based on entity type, and a predicate of any kind.
        
        :param: entityName The type of managed object to fetch
        :param: predicate  The predicate describing the objects to fetch
        :param: sortDescriptions The sort descriptors used to sort the results
        
        :returns: An array of sorted objects matching the predicate
        */
        public func fetchResults(entityName: String!, predicate: NSPredicate?, sortDescriptors: [AnyObject]?) -> [AnyObject]? {
                var error: NSError?
                let fetchRequest = NSFetchRequest()
                
                let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
                fetchRequest.entity = entity
                
                if predicate != nil {
                        fetchRequest.predicate = predicate
                }
                
                if sortDescriptors != nil {
                        fetchRequest.sortDescriptors = sortDescriptors
                }
                
                let fetchedObjects = context.executeFetchRequest(fetchRequest, error:&error)
                
                return fetchedObjects
        }
        
        /**
        Convience function to fetch sorted results from the managed object context based on entity type.
        
        :param: entityName The type of managed object to fetch
        :param: sortDescriptions The sort descriptors used to sort the results
        
        :returns: An array of sorted objects
        */
        public func fetchResults(entityName: String!,  sortDescriptors: [AnyObject]?) -> [AnyObject]? {
                return fetchResults(entityName, predicate: nil, sortDescriptors: sortDescriptors)
        }
        
        /**
        Helper function to create a new entity of a managed object. This funccion will insert the object into the context and save.
        
        :param: entityName The type of object to create
        
        :returns: The newly created object
        */
        public func newEntity(entityName: String!) -> AnyObject! {
                let newEntity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
                save()
                return newEntity
        }
}