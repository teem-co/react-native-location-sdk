import Foundation
import CoreLocation

open class Location: NSObject, CLLocationManagerDelegate {
  public static let shared = Location()
  
  private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
  private let defaults = UserDefaults.standard

  lazy var locationManager: CLLocationManager = {
    var manager: CLLocationManager!
    let op = BlockOperation {
        print("Main thread: \(Thread.isMainThread ? "YES" : "NO")")
        manager = CLLocationManager()
    }
    OperationQueue.main.addOperation(op)
    op.waitUntilFinished()
    return manager
  }()
  var currentLocation: CLLocationCoordinate2D?
  
  private override init() {
    super.init()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 10
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.showsBackgroundLocationIndicator = true
  }
  
  func getAuthorizationStatus() -> String {
    if #available(iOS 14.0, *) {
      switch locationManager.authorizationStatus {
      case .authorizedAlways:
        return "always"
      case .authorizedWhenInUse:
        return "when_in_use"
      case .denied:
        return "denied"
      case .restricted:
        return "restricted"
      case .notDetermined:
        return "not_determined"
      default:
        return "not_determined"
      }
    } else {
      return "not_determined"
    }
  }
  
  func requestPermission() -> String {
    locationManager.requestAlwaysAuthorization()
    
    return self.getAuthorizationStatus()
  }
  
  func start() {
    locationManager.startUpdatingLocation()
    defaults.setValue(true, forKey: "enabled")
    LocationEventEmitter.instance.dispatch(name: "enabled_changed", body: true)
  }
  
  func stop() {
    locationManager.stopUpdatingLocation()
    defaults.setValue(false, forKey: "enabled")
    LocationEventEmitter.instance.dispatch(name: "enabled_changed", body: false)
  }

  func getState() -> NSMutableDictionary {
    let state: NSMutableDictionary = ["enabled": defaults.bool(forKey: "enabled")]
    
    return state
  }
  
  func isEnabled() -> Bool {
    return defaults.bool(forKey: "enabled")
  }
  
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    concurrentQueue.sync {
      currentLocation = manager.location?.coordinate

      if let location = locations.first {
        NSLog("location")
        LocationEventEmitter.instance.dispatch(name: "location", body: self.serializeLocation(location: location))
      }
    }
  }
  
  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    LocationEventEmitter.instance.dispatch(name: "changeAuthorization", body: self.getAuthorizationStatus())
  }

  private func serializeLocation(location: CLLocation) -> NSMutableDictionary {
    let utcISODateFormatter = ISO8601DateFormatter()
    let dictionary: NSMutableDictionary = [:]
    
    dictionary["coordinate"] = [
      "longitude": location.coordinate.longitude,
      "latitude": location.coordinate.latitude
    ]
    dictionary["altitude"] = location.altitude
    dictionary["timestamp"] = utcISODateFormatter.string(from: location.timestamp)
    dictionary["course"] = location.course
    dictionary["horizontalAccuracy"] = location.horizontalAccuracy
    dictionary["speed"] = location.speed
    dictionary["verticalAccuracy"] = location.verticalAccuracy
//    dictionary["courseAccuracy"] = location.courseAccuracy
//    dictionary["ellipsoidalAltitude"] = location.ellipsoidalAltitude
    dictionary["floor"] = location.floor
//    dictionary["sourceInformation"] = location.sourceInformation
    dictionary["speedAccuracy"] = location.speedAccuracy

    if #available(iOS 13.0, *) {
      dictionary["activity"] = Motion.activity
    }

    return dictionary
  }
}
