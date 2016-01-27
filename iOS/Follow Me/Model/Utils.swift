//
//  Utils.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 06.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import Foundation
import GoogleMaps

public enum TravelModes: Int {
  case Driving
  case Walking
  case Bicycling
}

public protocol MapSettingsDelegate {
  func setMapSettings(mapType: GMSMapViewType, travelMode: TravelModes) -> Void
}

public class Util {
  
  public static let mainColor = UIColor(red: 51/255, green: 94/255, blue: 64/255, alpha: 1.0)
  
  public class func createErrorPopup(mess: String) -> Popup {
    let popup = Popup(title: "Error", subTitle: mess, textFieldPlaceholders: nil, cancelTitle: "Close", successTitle: nil, cancelBlock: nil, successBlock: nil)
    
    popup.backgroundColor = UIColor.flatWhiteColor()
    popup.borderColor = UIColor.flatBlackColor()
    popup.titleColor = UIColor.darkTextColor()
    popup.subTitleColor = UIColor.darkTextColor()
    
    popup.incomingTransition = PopupIncomingTransitionType.SlideFromTop
    popup.outgoingTransition = PopupOutgoingTransitionType.SlideToTop
    
    popup.backgroundBlurType = PopupBackGroundBlurType.Dark
    popup.roundedCorners = true
    
    popup.tapBackgroundToDismiss = false
    popup.swipeToDismiss = false
    
    return popup
  }
  
  public class func formatTimeFromSec(totalDurationInSeconds: UInt) -> String {
    let days = totalDurationInSeconds / 86400
    let b = totalDurationInSeconds % 86400
    let hours = b / 3600
    let d = b % 3600
    let minutes = d / 60
    let seconds = d % 60
    
    var totalDuration = "Duration: "
    var needComa = false
    if days != 0 {
      if days == 1 { totalDuration += "1 day" }
      else { totalDuration += "\(days) days" }
      needComa = true
    }
    
    if hours != 0 {
      if hours == 1 {
        if needComa { totalDuration += ", 1 hour" }
        else { totalDuration += "1 hour" }
      } else {
        if needComa { totalDuration += ", \(hours) hours" }
        else { totalDuration += "\(hours) hours" }
      }
      needComa = true
    }
    
    if minutes != 0 {
      if minutes == 1 {
        if needComa { totalDuration += ", 1 min" }
        else { totalDuration += "1 min" }
      } else {
        if needComa { totalDuration += ", \(minutes) mins" }
        else { totalDuration += "\(minutes) mins" }
      }
      needComa = true
    }
    
    if seconds != 0 {
      if seconds == 1 {
        if needComa { totalDuration += ", 1 sec" }
        else { totalDuration += "1 sec" }
      } else {
        if needComa { totalDuration += ", \(seconds) secs" }
        else { totalDuration += "\(seconds) secs" }
      }
    }
    
    return totalDuration
  }
}
