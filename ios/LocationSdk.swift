import Foundation
import CoreLocation

@objc(LocationSdk)
class LocationSdk: RCTEventEmitter {

  override init() {
    super.init()
    LocationEventEmitter.instance.registerEventEmitter(eventEmitter: self)
  }
  
  @objc(requestPermission:withRejecter:)
  func requestPermission(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    resolve(Location.shared.requestPermission())
  }
  
  @objc(getPermissionStatus:withRejecter:)
  func getPermissionStatus(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    resolve(Location.shared.getAuthorizationStatus())
  }
  
  @objc(start:withRejecter:)
  func start(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    Location.shared.start()
    resolve(nil)
  }
  
  @objc(stop:withRejecter:)
  func stop(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    Location.shared.stop()
    resolve(nil)
  }

  @objc(isEnabled:withRejecter:)
  func isEnabled(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    resolve(Location.shared.isEnabled())
  }
  
  @objc open override func supportedEvents() -> [String] {
    return LocationEventEmitter.instance.allEvents
  }
}
