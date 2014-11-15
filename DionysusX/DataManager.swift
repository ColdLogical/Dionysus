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
    lazy var readContext: NSManagedObjectContext? = {
        if let coordinator = self.persistentStoreCoordinator {
            var context = NSManagedObjectContext()
            context.persistentStoreCoordinator = self.persistentStoreCoordinator
            return context
        }
        assert(true, "Unable to create read context")
        return nil
    }()
    
    lazy var writeContext: NSManagedObjectContext? = {
        if let coordinator = self.persistentStoreCoordinator {
            var context = NSManagedObjectContext()
            context.persistentStoreCoordinator = self.persistentStoreCoordinator
            return context
        }
        assert(true, "Unable to create write context")
        return nil
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel? = {
        if let modelURL = NSBundle.mainBundle().URLForResource("DionysusXModel", withExtension:"momd") {
            return NSManagedObjectModel(contentsOfURL: modelURL)
        }
        assert(true, "Unable to create managed object model")
        return nil
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let storeURL = self.applicationDocumentsDirectory().URLByAppendingPathComponent("ProjectName.sqlite")
        var error: NSError?
        if let mom = self.managedObjectModel {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            if let finalCoordinator = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                return coordinator
            } else {
                println("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
        assert(true, "Unable to create persistent store")
        return nil
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
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
    }
    
    func save() {
        var error: NSError?
        if let context = writeContext {
            if context.hasChanges && !context.save(&error) {
                println("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}