//
//  AppData.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 27.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//
import Foundation
import CoreLocation
import GoogleMaps

public class AppData {
  
  public static let locationManager = CLLocationManager()
  public static let mapState = MapStateMemento()
  static var account: Account?
  
  public static var travelMode = TravelModes.Driving {
    didSet {
      delegate?.setMapSettings(self.mapType, travelMode: self.travelMode)
    }
  }
  public static var mapType = kGMSTypeNormal {
    didSet {
      delegate?.setMapSettings(self.mapType, travelMode: self.travelMode)
    }
  }
  
  public static var delegate: MapSettingsDelegate?
}

