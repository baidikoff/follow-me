//
//  SettingsTableViewController.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 07.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//
import UIKit
import GoogleMaps

class SettingsTableViewController: UITableViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController!.hidesNavigationBarHairline = true
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Travel Mode"
    default: return "Map Type"
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0: let cell = tableView.dequeueReusableCellWithIdentifier("travelMode")
      switch indexPath.row {
      case 0: cell?.textLabel?.text = "Driving"
        cell?.accessoryType = .Checkmark
      case 1: cell?.textLabel?.text = "Walking"
        cell?.accessoryType = .None
      default: cell?.textLabel?.text = "Bicycling"
        cell?.accessoryType = .None
      }
    return cell!
    default: let cell = tableView.dequeueReusableCellWithIdentifier("mapType")
      switch indexPath.row {
      case 0: cell?.textLabel?.text = "Normal"
        cell?.accessoryType = .Checkmark
      case 1: cell?.textLabel?.text = "Terrain"
        cell?.accessoryType = .None
      default: cell?.textLabel?.text = "Hybrid"
        cell?.accessoryType = .None
      }
    return cell!
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      for var j = 0; j < 3; j++ {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: 0))?.accessoryType = .None
      }
      switch indexPath.row {
      case 0: AppData.travelMode = .Driving
      case 1: AppData.travelMode = .Walking
      default: AppData.travelMode = .Bicycling
      }
    default:
      for var j = 0; j < 3; j++ {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: 1))?.accessoryType = .None
      }
      switch indexPath.row {
      case 0: AppData.mapType = kGMSTypeNormal
      case 1: AppData.mapType = kGMSTypeTerrain
      default: AppData.mapType = kGMSTypeHybrid
      }
    }
    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}