//
//  DataManager.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory().URLByAppendingPathComponent("Dionysus.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
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

    lazy var context: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        
        if coordinator == nil {
            return nil
        }
        
        var context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("DionysusModel", withExtension:"momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    class var sharedInstance: DataManager {
        struct Static {
            static var instance: DataManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataManager()
        }
        
        return Static.instance!
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
    }
    
    func save() {
        var error: NSError?
        if let c = context {
            if c.hasChanges && !c.save(&error) {
                println("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: Helper Functions
    func existingOrNewEntity(entityName: String!, predicate: NSPredicate?) -> AnyObject! {
        let results = fetchResults(entityName, predicate: predicate)
        if results != nil {
            if results!.count > 0 {
                assert(results!.count == 1, "Cannot have multiple entities with same identifier")
                return results![0]
            }
        }
        
        return newEntity(entityName)
    }
    
    func fetchResults(entityName: String!, predicate: NSPredicate?) -> [AnyObject]? {
        var error: NSError?
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context!)
        fetchRequest.entity = entity
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        let fetchedObjects = context!.executeFetchRequest(fetchRequest, error:&error)
        
        return fetchedObjects
    }
    
    func newEntity(entityName: String!) -> AnyObject! {
        let newEntity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context!)
        println("newEntity = \(newEntity)")
        save()
        
//        if let results =  fetchResults(entityName, predicate: NSPredicate(format: "objectID == %@", newEntity.objectID)) {
//            
//        }
        
        return newEntity
    }
}