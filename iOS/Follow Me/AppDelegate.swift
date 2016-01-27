//
//  AppDelegate.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 07.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import ChameleonFramework
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  // MARK: - APP Lifecycle
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    
    UITabBar.appearance().barTintColor = Util.mainColor
    UITabBar.appearance().tintColor = UIColor.flatWhiteColor()
    UITabBar.appearance().translucent = false
    UITabBar.appearance().shadowImage = UIImage()
    UITabBar.appearance().backgroundImage = UIImage()
    
    UINavigationBar.appearance().barTintColor = Util.mainColor
    UINavigationBar.appearance().barStyle = .Black
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor(), NSFontAttributeName: UIFont(name: "Helvetica Light", size: 18)!]

    GMSServices.provideAPIKey("AIzaSyAYixsK-UOMUNdmIGkUDNPc-nmeeKvmYYw")
    return true
  }
  
  func applicationWillTerminate(application: UIApplication) {
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  lazy var applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("Follow_Me", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    
    return coordinator
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  // MARK: - Core Data Saving support
  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
  
}

