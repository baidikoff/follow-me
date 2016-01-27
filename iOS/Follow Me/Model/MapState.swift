//
//  MapState.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 11.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import Foundation
import GoogleMaps

public class MapState {
  var originText: String?
  var destinationText: String?
  var routeInfo: String?
  var zoom: Float?
  var originMarker: GMSMarker?
  var destinationMarker: GMSMarker?
  var routePolyline: GMSPolyline?
  
  var markersArray: Array<GMSMarker>?
  var waypointsArray: Array<String>?
  
  public func insertData(originText: String?, destinationText: String?, routeInfo: String?, zoom: Float?, originMarker: GMSMarker?, destinationMarker: GMSMarker?, routePolyline: GMSPolyline?, markersArray: Array<GMSMarker>?, waypointsArray: Array<String>?) {
    self.originText = originText
    self.destinationText = destinationText
    self.routeInfo = routeInfo
    self.zoom = zoom
    self.originMarker = originMarker
    self.destinationMarker = destinationMarker
    self.routePolyline = routePolyline
    
    self.markersArray = markersArray
    self.waypointsArray = waypointsArray
  }
}