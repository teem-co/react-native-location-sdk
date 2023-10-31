import Foundation

class LocationEventEmitter {
  public static var instance = LocationEventEmitter()
  private static var eventEmitter: LocationSdk!
  
  private init() {}
  
  func registerEventEmitter(eventEmitter: LocationSdk) {
    LocationEventEmitter.eventEmitter = eventEmitter
  }
  
  func dispatch(name: String, body: Any?) {
    LocationEventEmitter.eventEmitter.sendEvent(withName: name, body: body)
  }

  lazy var allEvents: [String] = {
    var allEventNames: [String] = []

    allEventNames.append("location")
    allEventNames.append("changeAuthorization")
    allEventNames.append("enabled_changed")
    
    return allEventNames
  }()
}
