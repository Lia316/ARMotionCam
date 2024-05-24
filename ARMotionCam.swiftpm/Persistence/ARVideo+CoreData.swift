//
//  ARVideo+CoreData.swift
//  ARMotionCam
//
//  Created by 리아 on 5/14/24.
//
//

import CoreData

@objc(ARVideo)
class ARVideo: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ARVideo> {
        return NSFetchRequest<ARVideo>(entityName: "ARVideo")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var index: Int32
    @NSManaged public var videoUrl: String?
    @NSManaged public var cameraInfo: NSOrderedSet?
    @NSManaged public var modelInfo: NSOrderedSet?
    
    public var cameraInfoArray: [SpaceTime] {
        return cameraInfo?.array as? [SpaceTime] ?? []
    }
    public var modelInfoArray: [SpaceTime] {
        return modelInfo?.array as? [SpaceTime] ?? []
    }

}

// MARK: Generated accessors for cameraInfo
extension ARVideo {

    @objc(insertObject:inCameraInfoAtIndex:)
    @NSManaged public func insertIntoCameraInfo(_ value: SpaceTime, at idx: Int)

    @objc(removeObjectFromCameraInfoAtIndex:)
    @NSManaged public func removeFromCameraInfo(at idx: Int)

    @objc(insertCameraInfo:atIndexes:)
    @NSManaged public func insertIntoCameraInfo(_ values: [SpaceTime], at indexes: NSIndexSet)

    @objc(removeCameraInfoAtIndexes:)
    @NSManaged public func removeFromCameraInfo(at indexes: NSIndexSet)

    @objc(replaceObjectInCameraInfoAtIndex:withObject:)
    @NSManaged public func replaceCameraInfo(at idx: Int, with value: SpaceTime)

    @objc(replaceCameraInfoAtIndexes:withCameraInfo:)
    @NSManaged public func replaceCameraInfo(at indexes: NSIndexSet, with values: [SpaceTime])

    @objc(addCameraInfoObject:)
    @NSManaged public func addToCameraInfo(_ value: SpaceTime)

    @objc(removeCameraInfoObject:)
    @NSManaged public func removeFromCameraInfo(_ value: SpaceTime)

    @objc(addCameraInfo:)
    @NSManaged public func addToCameraInfo(_ values: NSOrderedSet)

    @objc(removeCameraInfo:)
    @NSManaged public func removeFromCameraInfo(_ values: NSOrderedSet)

}

// MARK: Generated accessors for modelInfo
extension ARVideo {

    @objc(insertObject:inModelInfoAtIndex:)
    @NSManaged public func insertIntoModelInfo(_ value: SpaceTime, at idx: Int)

    @objc(removeObjectFromModelInfoAtIndex:)
    @NSManaged public func removeFromModelInfo(at idx: Int)

    @objc(insertModelInfo:atIndexes:)
    @NSManaged public func insertIntoModelInfo(_ values: [SpaceTime], at indexes: NSIndexSet)

    @objc(removeModelInfoAtIndexes:)
    @NSManaged public func removeFromModelInfo(at indexes: NSIndexSet)

    @objc(replaceObjectInModelInfoAtIndex:withObject:)
    @NSManaged public func replaceModelInfo(at idx: Int, with value: SpaceTime)

    @objc(replaceModelInfoAtIndexes:withModelInfo:)
    @NSManaged public func replaceModelInfo(at indexes: NSIndexSet, with values: [SpaceTime])

    @objc(addModelInfoObject:)
    @NSManaged public func addToModelInfo(_ value: SpaceTime)

    @objc(removeModelInfoObject:)
    @NSManaged public func removeFromModelInfo(_ value: SpaceTime)

    @objc(addModelInfo:)
    @NSManaged public func addToModelInfo(_ values: NSOrderedSet)

    @objc(removeModelInfo:)
    @NSManaged public func removeFromModelInfo(_ values: NSOrderedSet)

}
