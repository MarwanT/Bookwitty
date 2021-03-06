//
//  Device.swift
//  Bookwitty
//
//  Created by Marwan  on 5/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

// MARK: -
public extension UIDevice {
  
  /// Returns the `DeviceType` of the device in use
  public var deviceType: DeviceType {
    return DeviceType.current
  }
}

/// Enum representing the different types of iOS devices available
public enum DeviceType: String, EnumProtocol {
  case iPhone2G
  case iPhone3G
  case iPhone3GS
  case iPhone4
  case iPhone4S
  case iPhone5
  case iPhone5C
  case iPhone5S
  case iPhone6Plus
  case iPhone6
  case iPhone6S
  case iPhone6SPlus
  case iPhone7
  case iPhone7Plus
  case iPhoneSE
  
  case iPodTouch1G
  case iPodTouch2G
  case iPodTouch3G
  case iPodTouch4G
  case iPodTouch5G
  
  case iPad
  case iPad2
  case iPad3
  case iPad4
  case iPadMini
  case iPadMiniRetina
  case iPadMini3
  case iPadMini4
  
  case iPadAir
  case iPadAir2
  
  case iPadPro9Inch
  case iPadPro12Inch
  
  case simulator
  case notAvailable
  
  // MARK: Constants
  
  /// Returns the current device type
  public static var current: DeviceType {
    
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machine = systemInfo.machine
    let mirror = Mirror(reflecting: machine)
    var identifier = ""
    
    for child in mirror.children {
      if let value = child.value as? Int8, value != 0 {
        identifier.append(String(UnicodeScalar(UInt8(value))))
      }
    }
    
    return DeviceType(identifier: identifier)
  }
  
  // MARK: Variables
  
  /// Returns the display name of the device type
  public var displayName: String {
    
    switch self {
    case .iPhone2G: return "iPhone 2G"
    case .iPhone3G: return "iPhone 3G"
    case .iPhone3GS: return "iPhone 3GS"
    case .iPhone4: return "iPhone 4"
    case .iPhone4S: return "iPhone 4S"
    case .iPhone5: return "iPhone 5"
    case .iPhone5C: return "iPhone 5C"
    case .iPhone5S: return "iPhone 5S"
    case .iPhone6Plus: return "iPhone 6 Plus"
    case .iPhone6: return "iPhone 6"
    case .iPhone6S: return "iPhone 6S"
    case .iPhone6SPlus: return "iPhone 6S Plus"
    case .iPhone7: return "iPhone 7"
    case .iPhone7Plus: return "iPhone 7 Plus"
    case .iPhoneSE: return "iPhone SE"
    case .iPodTouch1G: return "iPod Touch 1G"
    case .iPodTouch2G: return "iPod Touch 2G"
    case .iPodTouch3G: return "iPod Touch 3G"
    case .iPodTouch4G: return "iPod Touch 4G"
    case .iPodTouch5G: return "iPod Touch 5G"
    case .iPad: return "iPad"
    case .iPad2: return "iPad 2"
    case .iPad3: return "iPad 3"
    case .iPad4: return "iPad 4"
    case .iPadMini: return "iPad Mini"
    case .iPadMiniRetina: return "iPad Mini Retina"
    case .iPadMini3: return "iPad Mini 3"
    case .iPadMini4: return "iPad Mini 4"
    case .iPadAir: return "iPad Air"
    case .iPadAir2: return "iPad Air 2"
    case .iPadPro9Inch: return "iPad Pro 9 Inch"
    case .iPadPro12Inch: return "iPad Pro 12 Inch"
    case .simulator: return "Simulator"
    case .notAvailable: return "Not Available"
    }
  }
  
  internal var identifiers: [String] {
    
    switch self {
    case .notAvailable: return []
    case .simulator: return ["i386", "x86_64"]
      
    case .iPhone2G: return ["iPhone1,1"]
    case .iPhone3G: return ["iPhone1,2"]
    case .iPhone3GS: return ["iPhone2,1"]
    case .iPhone4: return ["iPhone3,1", "iPhone3,2", "iPhone3,3"]
    case .iPhone4S: return ["iPhone4,1"]
    case .iPhone5: return ["iPhone5,1", "iPhone5,2"]
    case .iPhone5C: return ["iPhone5,3", "iPhone5,4"]
    case .iPhone5S: return ["iPhone6,1", "iPhone6,2"]
    case .iPhone6Plus: return ["iPhone7,1"]
    case .iPhone6: return ["iPhone7,2"]
    case .iPhone6S: return ["iPhone8,1"]
    case .iPhone6SPlus: return ["iPhone8,2"]
    case .iPhone7: return ["iPhone9,1", "iPhone9,3"]
    case .iPhone7Plus: return ["iPhone9,2", "iPhone9,4"]
    case .iPhoneSE: return ["iPhone8,4"]
      
    case .iPodTouch1G: return ["iPod1,1"]
    case .iPodTouch2G: return ["iPod2,1"]
    case .iPodTouch3G: return ["iPod3,1"]
    case .iPodTouch4G: return ["iPod4,1"]
    case .iPodTouch5G: return ["iPod5,1"]
      
    case .iPad: return ["iPad1,1", "iPad1,2"]
    case .iPad2: return ["iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4"]
    case .iPad3: return ["iPad3,1", "iPad3,2", "iPad3,3"]
    case .iPad4: return ["iPad3,4", "iPad3,5", "iPad3,6"]
    case .iPadMini: return ["iPad2,5", "iPad2,6", "iPad2,7"]
    case .iPadMiniRetina: return ["iPad4,4", "iPad4,5", "iPad4,6"]
    case .iPadMini3: return ["iPad4,7", "iPad4,8"]
    case .iPadMini4: return ["iPad5,1", "iPad5,2"]
    case .iPadAir: return ["iPad4,1", "iPad4,2", "iPad4,3"]
    case .iPadAir2: return ["iPad5,3", "iPad5,4"]
    case .iPadPro9Inch: return ["iPad6,3", "iPad6,4"]
    case .iPadPro12Inch: return ["iPad6,7", "iPad6,8"]
    }
  }
  
  // MARK: Inits
  
  /** Creates a device type
   - parameter identifier: The identifier of the device
   - returns: The device type based on the provided identifier
   */
  internal init(identifier: String) {
    
    for device in DeviceType.all {
      for deviceId in device.identifiers {
        guard identifier == deviceId else { continue }
        self = device
        return
      }
    }
    
    self = .notAvailable
  }
}


// MARK:
internal protocol EnumProtocol: Hashable {
  /// Returns All Enum Values
  static var all: [Self] { get }
}

// MARK: -
// MARK: - Extensions
internal extension EnumProtocol where Self:Hashable {
  
  static var all: [Self] {
    typealias Type = Self
    let cases = AnySequence { () -> AnyIterator<Type> in
      var raw = 0
      return AnyIterator {
        let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: Type.self, capacity: 1) { $0.pointee } }
        guard current.hashValue == raw else { return nil }
        raw += 1
        return current
      }
    }
    
    return Array(cases)
  }
}
