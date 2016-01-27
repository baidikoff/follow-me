//
//  StateMemento.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 11.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import Foundation

public class MapStateMemento {
  
  private var memento : MapState?
  
  private func _saveState(state: MapState) {
    self.memento = state
  }
  
  private func _restoreState() -> MapState? {
    return memento
  }
  
  public func saveState(state: MapState) {
    _saveState(state)
  }
  
  public func restoreState() -> MapState? {
    return _restoreState()
  }
}
