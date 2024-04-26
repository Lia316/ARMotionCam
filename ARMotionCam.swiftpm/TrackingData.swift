//
//  TrackingData.swift
//  ARMotionCam
//
//  Created by 리아 on 4/12/24.
//

import CoreData
import SwiftUI

@objc(TrackingData)
class TrackingData: NSManagedObject {
    @NSManaged var type: String
    @NSManaged var timestamp: Date
    @NSManaged var positionX: Float
    @NSManaged var positionY: Float
    @NSManaged var positionZ: Float
    @NSManaged var orientationX: Float
    @NSManaged var orientationY: Float
    @NSManaged var orientationZ: Float
    @NSManaged var orientationW: Float
}

extension TrackingData: Identifiable {
    var id: Int {
        Int(timestamp.timeIntervalSince1970)
    }
}
