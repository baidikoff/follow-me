//
//  Route.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 06.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import Foundation
import CoreData
import ChameleonFramework

@objc(Route)
class Route: NSManagedObject {
  @NSManaged var name: NSString?
  @NSManaged var address: NSString?
  @NSManaged var desc: NSString?
  @NSManaged var account: Account?
  
  class func create(moc: NSManagedObjectContext, name: String, address: String, desc: String, account: Account) -> Route {
    let newRoute = NSEntityDescription.insertNewObjectForEntityForName("Route", inManagedObjectContext: moc) as! Route
    newRoute.name = name
    newRoute.address = address
    newRoute.desc = desc
    newRoute.account = account

    return newRoute
  }
}