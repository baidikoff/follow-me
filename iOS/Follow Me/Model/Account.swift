//
//  Account.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 08.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import Foundation
import CoreData

@objc(Account)
class Account: NSManagedObject {
  @NSManaged var age: NSInteger
  @NSManaged var birthDate: NSDate
  @NSManaged var email: NSString
  @NSManaged var login: NSString
  @NSManaged var name: NSString
  @NSManaged var password: NSString
  
  class func create(inMoc moc: NSManagedObjectContext, age: Int, birthDate: NSDate, email: String, login: String, name: String, password: String) -> Account {
    let newAccount = NSEntityDescription.insertNewObjectForEntityForName("Account", inManagedObjectContext: moc) as! Account
    newAccount.age = age
    newAccount.birthDate = birthDate
    newAccount.email = email
    newAccount.login = login
    newAccount.name = name
    newAccount.password = password
    
    return newAccount
  }
}
