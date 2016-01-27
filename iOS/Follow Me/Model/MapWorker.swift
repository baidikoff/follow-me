//
//  MapWorker.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 23.11.15.
//  Copyright © 2015 Follow. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import AddressBookUI

class MapWorker {
  
  // MARK: - Geocoding address
  let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
  var lookupAddressResults: Dictionary<NSObject, AnyObject>!
  var fetchedFormattedAddress: String!
  var fetchedAddressLongitude: Double!
  var fetchedAddressLatitude: Double!
  
  func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
    if let lookupAddress = address {
      var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
      geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
      
      let geocodeURL = NSURL(string: geocodeURLString)
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
        var dictionary = Dictionary<NSObject, AnyObject>()
        do {
          dictionary = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
        } catch {
          
        }
        let status = dictionary["status"] as! String
        
        if status == "OK" {
          let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
          self.lookupAddressResults = allResults[0]
          
          self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
          let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
          self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
          self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
          
          completionHandler(status: status, success: true)
        }
        else {
          completionHandler(status: status, success: false)
        }
      })
    } else {
      completionHandler(status: "No valid address.", success: false)
    }
  }
  
  // MARK: - Geocode cooridnates
  var address: String!
  
  func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (status: String, success: Bool) -> Void) {
    let url = NSURL(string: "\(baseURLGeocode)latlng=\(coordinate.latitude),\(coordinate.longitude)")
    dispatch_async(dispatch_get_main_queue()) {
      let data = NSData(contentsOfURL: url!)
      let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
      if let result = json["results"] as? NSArray {
        self.address = result[0]["formatted_address"] as? String
        completionHandler(status: "OK", success: true)
      } else {
        completionHandler(status: "No such address", success: false)
      }
    }
  }
  
  // MARK: - Directions
  let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
  var selectedRoute: Dictionary<NSObject, AnyObject>!
  var overviewPolyline: Dictionary<NSObject, AnyObject>!
  var originCoordinate: CLLocationCoordinate2D!
  var destinationCoordinate: CLLocationCoordinate2D!
  var originAddress: String!
  var destinationAddress: String!
  var lastDirectionsURL: NSURL?
  
  func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: ((status: String, success: Bool) -> Void)) {
    if let originLocation = origin {
      if let destinationLocation = destination {
        
        var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
        
        if let routeWaypoints = waypoints {
          directionsURLString += "&waypoints=optimize:true"
          
          for waypoint in routeWaypoints {
            directionsURLString += "|" + waypoint
          }
        }
        
        if travelMode != nil {
          switch travelMode.rawValue {
          case TravelModes.Walking.rawValue: directionsURLString += "&mode=walking"
          case TravelModes.Bicycling.rawValue: directionsURLString += "&mode=bicycling"
          default: directionsURLString += "&mode=driving"
          }
        }
        directionsURLString = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let directionsURL = NSURL(string: directionsURLString)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          let directionsData = NSData(contentsOfURL: directionsURL!)
          var dictionary: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
          do {
            dictionary = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
          } catch let error as NSError {
            completionHandler(status: "\(error.localizedDescription)", success: false)
          }
          let status = dictionary["status"] as! String
          
          if status == "OK" {
            self.lastDirectionsURL = directionsURL
            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
            
            let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
            
            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
            
            self.originAddress = legs[0]["start_address"] as! String
            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
            
            self.calculateTotalDistanceAndDuration()
            completionHandler(status: status, success: true)
          }
          else {
            completionHandler(status: status, success: false)
          }
        })
      }
      else {
        completionHandler(status: "Destination is nil.", success: false)
      }
    }
    else {
      completionHandler(status: "Origin is nil", success: false)
    }
  }
  
  // MARK: - Distance
  var totalDistanceInMeters: UInt = 0
  var totalDistance: String!
  var totalDurationInSeconds: UInt = 0
  var totalDuration: String!
  
  func calculateTotalDistanceAndDuration() {
    let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
    
    totalDistanceInMeters = 0
    totalDurationInSeconds = 0
    
    for leg in legs {
      totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
      totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
    }
    
    let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
    totalDistance = "Total Distance: \(distanceInKilometers) Km"
    totalDuration = Util.formatTimeFromSec(totalDurationInSeconds)
  }
}

