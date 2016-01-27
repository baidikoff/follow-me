//
//  MapViewController.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 07.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import UIKit
import GoogleMaps
import ChameleonFramework
import FlatUIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, PopupDelegate, FUIAlertViewDelegate, MapSettingsDelegate {
  
  // MARK: - Storyboard Outlets stack
  @IBOutlet weak var menuButton: UIBarButtonItem!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var infoLabelBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Location stack
  let locationManager = AppData.locationManager
  var didFindMyLocation = false
  
  // MARK: - Waypoints stack
  var markersArray: Array<GMSMarker> = []
  var waypointsArray: Array<String> = []
  
  // MARK: - Routine stack
  var originText : String?
  var destinationText: String?
  var routeInfo : String?
  var zoom: Float?
  var originMarker: GMSMarker!
  var destinationMarker: GMSMarker!
  var routePolyline: GMSPolyline!
  var mapWorker = MapWorker()
  
  var travelMode = AppData.travelMode
  
  // MARK: - Save state stack
  let mapState = AppData.mapState
  
  // MARK: - VC Lifecycle stack
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AppData.delegate = self
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    mapView.delegate = self
    mapView.camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6)
    mapView.myLocationEnabled = true
    mapView.settings.compassButton = true
    
    infoLabelBottomConstraint.constant = CGFloat(60.0)
    mapViewBottomConstraint.constant = CGFloat(0.0)
    view.layoutIfNeeded()
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController!.hidesNavigationBarHairline = true
    tabBarController?.hidesBottomBarWhenPushed = true
    infoLabel.backgroundColor = Util.mainColor
    infoLabel.textColor = UIColor.flatWhiteColor()
    infoLabel.font = UIFont(name: "Helvetica Light", size: 16)!
  }
  
  // MARK: - Action handlers
  @IBAction func clearAll(sender: UIBarButtonItem) {
    clearRoute()
  }
  
  func setMapSettings(mapType: GMSMapViewType, travelMode: TravelModes) {
    self.mapView.mapType = mapType
    self.travelMode = travelMode
  }
  
  // MARK: - Map View delegate methods
  func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    if routePolyline != nil {
      let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
      waypointsArray.append(positionString)
      recreateRoute()
      return
    }
    
    mapWorker.reverseGeocodeCoordinate(coordinate) { (status, success) in
      if success {
        let position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.flat = true
        marker.title = self.mapWorker.address
        marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        marker.opacity = 0.75
      
        if self.originMarker == nil {
          self.originText = marker.title
          self.originMarker = marker
          self.originMarker.map = mapView
          return
        }
      
        if self.destinationMarker == nil {
          self.destinationText = marker.title
          self.destinationMarker = marker
          self.destinationMarker.map = mapView
          self.foundRoute()
          return
        }
      } else {
        self.showAlertWithMessage(status)
      }
    }
  }
  
  // MARK: - Value observer methods
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if !didFindMyLocation {
      let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
      mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
      mapView.settings.myLocationButton = true
      didFindMyLocation = true
    }
  }
  
  // MARK: - Location Manager delegate methods
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      mapView.myLocationEnabled = true
    }
    if status == CLAuthorizationStatus.Denied {
      mapView.myLocationEnabled = false
    }
  }
  
  // MARK: - Route methods
  func foundRoute() {
    self.mapWorker.getDirections(self.originText!, destination: self.destinationText!, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
      if success {
        if self.routePolyline != nil {
          self.clearRoute()
          self.waypointsArray.removeAll(keepCapacity: false)
        }
        self.configureMapAndMarkersForRoute()
        self.drawRoute()
        self.displayRouteInfo()
      }
      else {
        self.showAlertWithMessage(status)
      }
    })
  }
  
  func clearRoute() {
    originMarker?.map = nil
    destinationMarker?.map = nil
    routePolyline?.map = nil
    
    originMarker = nil
    destinationMarker = nil
    routePolyline = nil
    
    if markersArray.count > 0 {
      for marker in markersArray {
        marker.map = nil
      }
      markersArray.removeAll(keepCapacity: false)
    }
    
    UIView.animateWithDuration(0.2) {
      self.infoLabelBottomConstraint.constant = CGFloat(60.0)
      self.mapViewBottomConstraint.constant = CGFloat(0.0)
      self.view.layoutIfNeeded()
    }
    
  }
  
  func configureMapAndMarkersForRoute() {
    zoom = self.mapView.camera.zoom
    mapView.camera = GMSCameraPosition.cameraWithTarget(self.mapWorker.originCoordinate, zoom: zoom!)
    
    if originMarker != nil {
      originMarker.map = nil
      originMarker = nil
    }
    
    originMarker = GMSMarker(position: self.mapWorker.originCoordinate)
    originMarker.map = self.mapView
    originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
    originMarker.title = self.mapWorker.originAddress
    
    if destinationMarker != nil {
      destinationMarker.map = nil
      destinationMarker = nil
    }
    
    destinationMarker = GMSMarker(position: self.mapWorker.destinationCoordinate)
    destinationMarker.map = self.mapView
    destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
    destinationMarker.title = self.mapWorker.destinationAddress
    
    if waypointsArray.count > 0 {
      for waypoint in waypointsArray {
        let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
        let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
        
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
        marker.map = mapView
        marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
        
        markersArray.append(marker)
      }
    }
  }
  
  func drawRoute() {
    let route = mapWorker.overviewPolyline["points"] as! String
    let prevZoom = self.mapView.camera.zoom
    
    let path: GMSPath = GMSPath(fromEncodedPath: route)
    routePolyline = GMSPolyline(path: path)
    routePolyline.strokeColor = UIColor.flatBlueColor()
    routePolyline.strokeWidth = 5.0
    routePolyline.map = self.mapView
    
    if markersArray.count > 0 {
      mapView.camera = GMSCameraPosition.cameraWithTarget((self.markersArray.last?.position)!, zoom: prevZoom)
    }
  }
  
  func displayRouteInfo() {
    routeInfo = mapWorker.totalDistance + "\n" + mapWorker.totalDuration
    infoLabel.text = routeInfo
    UIView.animateWithDuration(0.2) {
      self.infoLabelBottomConstraint.constant = CGFloat(0.0)
      self.mapViewBottomConstraint.constant = CGFloat(60.0)
      self.view.layoutIfNeeded()
    }
  }
  
  func recreateRoute() {
    if routePolyline != nil {
      mapWorker.getDirections(mapWorker.originAddress, destination: mapWorker.destinationAddress, waypoints: waypointsArray, travelMode: travelMode, completionHandler: { (status, success) -> Void in
        
        if success {
          self.clearRoute()
          self.configureMapAndMarkersForRoute()
          self.drawRoute()
          self.displayRouteInfo()
        }
        else {
          self.showAlertWithMessage(status)
        }
      })
    }
  }
  
  // MARK: - Save and restore state method stack
  func saveCurrentSession() {
    let currentState = MapState()
    currentState.insertData(originText, destinationText: destinationText, routeInfo: routeInfo, zoom: zoom, originMarker: originMarker, destinationMarker: destinationMarker, routePolyline: routePolyline, markersArray: markersArray, waypointsArray: waypointsArray)
    mapState.saveState(currentState)
    
  }
  
  func restorePreviousSession() {
    let previousState = mapState.restoreState()
    if previousState != nil {
      self.originText = previousState?.originText
      self.originMarker = previousState?.originMarker
      self.originMarker.map = mapView
    
      self.destinationText = previousState?.destinationText
      self.destinationMarker = previousState?.destinationMarker
      self.destinationMarker.map = mapView
    
      self.routeInfo = previousState?.routeInfo
      self.zoom = previousState?.zoom
      self.routePolyline = previousState?.routePolyline
      self.routePolyline.map = mapView
    
      self.markersArray = (previousState?.markersArray)!
      self.waypointsArray = (previousState?.waypointsArray)!
      
      if markersArray.count > 0 {
        mapView.camera = GMSCameraPosition.cameraWithTarget((self.markersArray.last?.position)!, zoom: zoom!)
      }
      
      infoLabel.text = routeInfo
      UIView.animateWithDuration(0.2) {
        self.infoLabelBottomConstraint.constant = CGFloat(0.0)
        self.mapViewBottomConstraint.constant = CGFloat(60.0)
        self.view.layoutIfNeeded()
      }
    }
  }
  
  // MARK: - Popup delegate methods
  func dictionary(dictionary: NSMutableDictionary!, forpopup popup: Popup!, stringsFromTextFields stringArray: [AnyObject]!) {
    originText = stringArray[0] as? String
    destinationText = stringArray[1] as? String
  }
  
  // MARK: - Util methods
  func showAlertWithMessage(message: String) {
    Util.createErrorPopup(message).showPopup()
  }
}