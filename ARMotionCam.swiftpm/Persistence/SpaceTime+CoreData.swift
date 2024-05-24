//
//  SpaceTime+CoreData.swift
//  ARMotionCam
//
//  Created by 리아 on 5/14/24.
//
//

import Foundation
import CoreData


@objc(SpaceTime)
class SpaceTime: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpaceTime> {
        return NSFetchRequest<SpaceTime>(entityName: "SpaceTime")
    }

    @NSManaged public var orientationW: Float
    @NSManaged public var orientationX: Float
    @NSManaged public var orientationY: Float
    @NSManaged public var orientationZ: Float
    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var positionZ: Float
    @NSManaged public var timestamp: Date?
    @NSManaged public var modelInfoOrigin: ARVideo?
    @NSManaged public var cameraInfoOrigin: ARVideo?

    
    func stringForDebug() -> String {
        return """
                time: \(String(describing: timestamp))
                orientation (x, y, z, w): (\(orientationX), \(orientationY), \(orientationZ), \(orientationW))
                position (x, y, z): (\(positionX), \(positionY), \(positionZ))
                info origin: \(modelInfoOrigin == nil ? "camera" : "model"))
                """
    }
}
