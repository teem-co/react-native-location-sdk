import Foundation
import CoreMotion

@available(iOS 13.0, *)
open class Motion: NSObject {
  public static let instance = Motion()
  
  private static let motionManager = CMMotionManager()
  private static let activityManager = CMMotionActivityManager()
  public static var activity = "unknown"
  
  private override init() {
    super.init()
    
    Motion.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
  }
  
  func handleActivity(activity: CMMotionActivity?) {
    if activity?.stationary != nil {
      Motion.activity = "stationary"
    } else if activity?.walking != nil {
      Motion.activity = "walking"
    } else if activity?.running != nil {
      Motion.activity = "runnig"
    } else if activity?.cycling != nil {
      Motion.activity = "cycling"
    } else if activity?.automotive != nil {
      Motion.activity = "automotive"
    } else {
      Motion.activity = "unknown"
    }
  }
  
  func requestPermission(_ callback: ((Bool) -> ())?) {
    let now = Date()
    
    Motion.activityManager.queryActivityStarting(from: now, to: now, to: .main) { _, error in
      var status = false
      
      if let error = error, error._code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
        status = false
      } else {
        status = true
      }

      Motion.activityManager.stopActivityUpdates()
      
      callback?(status)
    }
  }
}
